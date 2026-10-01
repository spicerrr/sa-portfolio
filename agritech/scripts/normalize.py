"""Поиск по утверждённым ID; нормализация имени не создаёт mapping."""
import csv
import json
import unicodedata
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def normalized_name(value):
    return " ".join(unicodedata.normalize("NFKC", value).casefold().split())
def resolve():
    mappings = {}
    with (ROOT / "examples/source-mappings.csv").open() as stream:
        for row in csv.DictReader(stream):
            key = (row["source_system"], row["entity_type"], row["source_id"])
            if key in mappings:
                raise ValueError(f"Повтор ключа mapping: {key}")
            mappings[key] = row["variety_id"]
    result = []
    with (ROOT / "examples/source-records.csv").open() as stream:
        for row in csv.DictReader(stream):
            key = (row["source_system"], row["entity_type"], row["source_id"])
            master = mappings.get(key)
            result.append({"sourceId": row["source_id"],
                           "normalizedName": normalized_name(row["source_name"]),
                           "varietyId": master,
                           "status": "RESOLVED" if master else "UNRESOLVED"})
    return result
if __name__ == "__main__":
    print(json.dumps(resolve(), ensure_ascii=False, indent=2))
