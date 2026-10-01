BEGIN;
SET LOCAL search_path TO agri_demo;
INSERT INTO variety VALUES ('VAR-017', 'Golden Delicious', true);
INSERT INTO plot VALUES ('PLOT-044', 'Demo A'), ('PLOT-045', 'Demo B');
INSERT INTO plot_season VALUES
  ('PLOT-044', 2026, 'VAR-017', 2), ('PLOT-045', 2026, 'VAR-017', 3);
INSERT INTO harvest_batch
 (batch_id, plot_id, season, variety_id, source_system, source_record_id,
  harvest_date, weight_kg)
VALUES
 ('HB-2026-001284', 'PLOT-044', 2026, 'VAR-017', 'PRODUCTION', 'SRC-1284', '2026-08-14', 8420),
 ('HB-2026-001285', 'PLOT-044', 2026, 'VAR-017', 'PRODUCTION', 'SRC-1285', '2026-08-15', 1580),
 ('HB-2026-001286', 'PLOT-045', 2026, 'VAR-017', 'PRODUCTION', 'SRC-1286', '2026-08-16', 5000);
INSERT INTO receipt_projection(batch_id, lot_id, received_weight_kg, received_at)
 VALUES ('HB-2026-001284', 'LOT-2026-0781', 8370, '2026-08-14T10:00:00Z');
-- Dataset for metric verification; no publisher or outbox lifecycle simulated.
COMMIT;
SELECT * FROM agri_demo.variety_passport;
-- Expected: harvested_t=15; area_ha=5; yield=3; received_t=8.37;
-- receipt_coverage=1/3; matched_delta_t=-0.05.
