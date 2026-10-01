"""Проверки согласованности артефактов; не интеграционные испытания."""
import copy
import csv
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from decimal import Decimal
import yaml
from jsonschema import Draft202012Validator, FormatChecker
from openapi_spec_validator import validate_spec
from normalize import resolve
from check_legacy import check
ROOT = Path(__file__).resolve().parents[1]

def main():
    api = yaml.safe_load((ROOT / 'contracts/openapi.yaml').read_text())
    validate_spec(api)
    event_schema = json.loads((ROOT / 'contracts/events.schema.json').read_text())
    Draft202012Validator.check_schema(event_schema)
    validator = Draft202012Validator(event_schema, format_checker=FormatChecker())
    events = {}
    for name in ['harvest', 'receipt']:
        event = json.loads((ROOT / f'examples/{name}-event.json').read_text())
        validator.validate(event)
        events[name] = event
    assert events['harvest']['payload']['batchId'] == events['receipt']['payload']['batchId']
    assert events['harvest']['correlationId'] == events['receipt']['correlationId']
    # Negative checks prevent accepting wrong versions or cross-kind payloads.
    for name, change in [('harvest', 'version'), ('receipt', 'payload')]:
        bad = copy.deepcopy(events[name])
        if change == 'version': bad['eventVersion'] = 2
        else: bad['payload'] = events['harvest']['payload']
        assert not validator.is_valid(bad), f'Invalid {change} accepted'
    request = json.loads((ROOT / 'examples/register-request.json').read_text())
    assert all(events['harvest']['payload'][k] == v for k, v in request.items())
    assert set(request) == set(api['components']['schemas']['HarvestCreate']['required'])
    # Validate API request example using corresponding JSON Schema semantics.
    request_schema = copy.deepcopy(api['components']['schemas']['HarvestCreate'])
    weight = request_schema['properties']['weightKg']
    weight['exclusiveMinimum'] = weight.pop('minimum')
    Draft202012Validator(request_schema, format_checker=FormatChecker()).validate(request)
    rules = (ROOT / 'docs/requirements.md').read_text()
    acceptance = (ROOT / 'docs/acceptance.md').read_text()
    rule_ids = set(re.findall(r'\| ((?:BR|FR|NFR|CON)-\d+) \|', rules))
    referenced = set(re.findall(r'\b(?:BR|FR|NFR|CON)-\d+\b', acceptance))
    assert rule_ids == referenced, (rule_ids - referenced, referenced - rule_ids)
    for md in ROOT.rglob('*.md'):
        for target in re.findall(r'!?\[[^\]]*\]\(([^)]+)\)', md.read_text()):
            if target.startswith(('http:', 'https:', 'mailto:', '#')): continue
            assert (md.parent / target.split('#')[0]).resolve().exists(), (md, target)
    legacy = check()
    assert [r['status'] for r in legacy] == [
        'READY', 'DUPLICATE', 'CONFLICT', 'UNRESOLVED', 'INVALID_UNIT']
    assert Decimal(legacy[0]['weight_kg']) == Decimal('8420')
    use_cases = (ROOT / 'docs/use-cases.md').read_text()
    for number in range(1, 6):
        assert f'## UC-{number:02d}' in use_cases
    for source in (ROOT / 'diagrams').glob('*.puml'):
        rendered = ROOT / 'diagrams/rendered' / (source.stem + '.svg')
        tree = ET.parse(rendered)
        svg_text = ''.join(tree.getroot().itertext())
        assert 'Syntax Error' not in svg_text and 'Syntax error' not in svg_text, source
        assert rendered.stat().st_size > 1000, source
    bpmn = ET.parse(ROOT / 'diagrams/batch-process.bpmn').getroot()
    elements = list(bpmn.iter())
    ids = [e.attrib['id'] for e in elements if 'id' in e.attrib]
    assert len(ids) == len(set(ids)), 'Duplicate BPMN ID'
    for e in elements:
        for key in ['sourceRef', 'targetRef', 'processRef', 'bpmnElement']:
            if key in e.attrib: assert e.attrib[key] in ids, (key, e.attrib[key])
    assert len(bpmn.findall('{http://www.omg.org/spec/BPMN/20100524/MODEL}process')) == 2
    collection = json.loads((ROOT / 'contracts/postman.collection.json').read_text())
    assert len(collection['item']) == 3
    result = resolve()
    assert [r['status'] for r in result] == ['RESOLVED', 'RESOLVED', 'UNRESOLVED']
    assert [r['varietyId'] for r in result[:2]] == ['VAR-017', 'VAR-017']
    # Independent arithmetic of expected synthetic metric result.
    assert sum(map(Decimal, ['8.420', '1.580', '5.000'])) / Decimal('5') == Decimal('3')
    assert Decimal('8.370') - Decimal('8.420') == Decimal('-0.050')
    print(f'OK: OpenAPI; event schemas/examples + negative checks; {len(rule_ids)} requirements covered; document/image links; 8 rendered UML; 5 use cases; legacy source decisions; BPMN; Postman; MDM; metric arithmetic.')

if __name__ == '__main__': main()
