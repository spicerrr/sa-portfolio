-- Локальная демонстрационная проекция, PostgreSQL. Не общая БД всех сервисов.
BEGIN;
CREATE SCHEMA IF NOT EXISTS agri_demo;
SET LOCAL search_path TO agri_demo;
CREATE TABLE variety (
    variety_id text PRIMARY KEY,
    canonical_name text NOT NULL,
    active boolean NOT NULL DEFAULT true
);
CREATE TABLE source_mapping (
    source_system text NOT NULL,
    entity_type text NOT NULL CHECK (entity_type = 'VARIETY'),
    source_id text NOT NULL,
    source_name text NOT NULL,
    variety_id text NOT NULL REFERENCES variety,
    PRIMARY KEY (source_system, entity_type, source_id)
);
CREATE TABLE plot (plot_id text PRIMARY KEY, plot_name text NOT NULL);
CREATE TABLE plot_season (
    plot_id text NOT NULL REFERENCES plot,
    season integer NOT NULL CHECK (season BETWEEN 2000 AND 2100),
    variety_id text NOT NULL REFERENCES variety,
    bearing_area_ha numeric(12,3) NOT NULL CHECK (bearing_area_ha > 0),
    PRIMARY KEY (plot_id, season),
    UNIQUE (plot_id, season, variety_id)
);
CREATE TABLE harvest_batch (
    batch_id text PRIMARY KEY,
    plot_id text NOT NULL,
    season integer NOT NULL,
    variety_id text NOT NULL,
    source_system text NOT NULL,
    source_record_id text NOT NULL,
    harvest_date date NOT NULL,
    weight_kg numeric(12,3) NOT NULL CHECK (weight_kg > 0),
    status text NOT NULL DEFAULT 'REGISTERED' CHECK (status = 'REGISTERED'),
    registered_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (source_system, source_record_id),
    FOREIGN KEY (plot_id, season, variety_id)
      REFERENCES plot_season(plot_id, season, variety_id),
    CHECK (EXTRACT(YEAR FROM harvest_date) = season)
);
CREATE TABLE receipt_projection (
    batch_id text PRIMARY KEY REFERENCES harvest_batch,
    lot_id text NOT NULL UNIQUE,
    received_weight_kg numeric(12,3) NOT NULL CHECK (received_weight_kg > 0),
    received_at timestamptz NOT NULL,
    projected_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE outbox (
    event_id uuid PRIMARY KEY,
    batch_id text NOT NULL UNIQUE REFERENCES harvest_batch,
    body jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    published_at timestamptz
);
CREATE TABLE inbox (
    consumer text NOT NULL,
    event_id uuid NOT NULL,
    processed_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (consumer, event_id)
);
CREATE TABLE idempotency_request (
    principal_id text NOT NULL,
    operation text NOT NULL,
    key uuid NOT NULL,
    request_hash text NOT NULL,
    response_body jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (principal_id, operation, key)
);
-- Проверки активности, будущей даты, immutable-фактов и прав выполняются сервисом.
-- Схема сама по себе не реализует весь контракт.
COMMIT;
