-- Архив и решения перехода. Отдельно от agri_demo, без записи в Production.
BEGIN;
CREATE SCHEMA IF NOT EXISTS agri_staging;
SET LOCAL search_path TO agri_staging;
CREATE TABLE source_snapshot (
    snapshot_id text PRIMARY KEY,
    source_system text NOT NULL,
    extracted_at timestamptz NOT NULL,
    source_file text NOT NULL,
    checksum_sha256 text NOT NULL CHECK (checksum_sha256 ~ '^[0-9a-f]{64}$')
);
CREATE TABLE raw_record (
    snapshot_id text NOT NULL REFERENCES source_snapshot,
    row_locator text NOT NULL,
    source_record_id text NOT NULL,
    raw_body jsonb NOT NULL,
    PRIMARY KEY (snapshot_id, row_locator)
);
CREATE TABLE load_decision (
    snapshot_id text NOT NULL,
    row_locator text NOT NULL,
    status text NOT NULL CHECK (status IN
        ('READY','DUPLICATE','CONFLICT','UNRESOLVED','INVALID_UNIT','INVALID_VALUE')),
    reason text NOT NULL,
    normalized_body jsonb,
    decided_by text NOT NULL,
    decided_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (snapshot_id, row_locator),
    FOREIGN KEY (snapshot_id, row_locator) REFERENCES raw_record
);
-- Идентичность не зависит от координат повторной выгрузки.
CREATE TABLE import_identity (
    source_system text NOT NULL,
    source_record_id text NOT NULL,
    canonical_body_hash text NOT NULL,
    batch_id text,
    PRIMARY KEY (source_system, source_record_id),
    UNIQUE (batch_id)
);
-- Фиксирует только подтверждённые связи; неоднозначные кандидаты остаются в raw/decision.
CREATE TABLE historical_receipt_link (
    production_system text NOT NULL,
    harvest_record_id text NOT NULL,
    warehouse_system text NOT NULL,
    receipt_record_id text NOT NULL,
    basis text NOT NULL,
    approved_by text NOT NULL,
    approved_at timestamptz NOT NULL,
    PRIMARY KEY (production_system, harvest_record_id),
    UNIQUE (warehouse_system, receipt_record_id)
);
-- Append-only снимки, журнал изменений решений и роли требуют реализации доступа.
COMMIT;
