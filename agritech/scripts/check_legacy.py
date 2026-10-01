"""Контроль синтетического снимка. Не выполняет импорт и не проверяет посадки."""
import csv
from decimal import Decimal, InvalidOperation
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def check():
    with (ROOT / 'examples/source-mappings.csv').open() as file:
        mappings = {(r['source_system'], r['source_id']): r['variety_id']
                    for r in csv.DictReader(file) if r['entity_type'] == 'VARIETY'}
    seen, results = {}, []
    with (ROOT / 'examples/legacy-harvest.csv').open() as file:
        for row in csv.DictReader(file):
            result = dict(row)
            unit = row['unit']
            key = (row['source_system'], row['source_record_id'])
            if unit not in ('кг', 'т'):
                result['status'] = 'INVALID_UNIT'
            else:
                try:
                    kg = Decimal(row['weight']) * (1000 if unit == 'т' else 1)
                    if not kg.is_finite() or kg <= 0 or kg != kg.quantize(Decimal('.001')):
                        raise ValueError('invalid mass')
                except (InvalidOperation, ValueError):
                    result['status'] = 'INVALID_VALUE'
                    results.append(result)
                    continue
                result['weight_kg'] = str(kg)
                variety = mappings.get((row['source_system'], row['source_variety_id']))
                if not variety:
                    result['status'] = 'UNRESOLVED'
                else:
                    body = (variety, kg, row['harvest_date'], row['plot_code'], row['season'])
                    result['status'] = ('READY' if key not in seen else
                                        'DUPLICATE' if seen[key] == body else 'CONFLICT')
                    seen.setdefault(key, body)
            results.append(result)
    return results

if __name__ == '__main__':
    for record in check():
        print(record['source_record_id'], record['status'])
