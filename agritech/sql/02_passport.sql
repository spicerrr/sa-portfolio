CREATE OR REPLACE VIEW agri_demo.variety_passport AS
WITH area AS (
    SELECT variety_id, season, SUM(bearing_area_ha) AS area_ha
    FROM agri_demo.plot_season GROUP BY variety_id, season
), facts AS (
    SELECT b.variety_id, b.season,
           COUNT(*) AS batch_count,
           SUM(b.weight_kg) / 1000.0 AS harvested_t,
           COUNT(r.batch_id) AS received_batch_count,
           COALESCE(SUM(r.received_weight_kg), 0) / 1000.0 AS received_t,
           SUM(r.received_weight_kg - b.weight_kg)
               FILTER (WHERE r.batch_id IS NOT NULL) / 1000.0 AS matched_delta_t,
           MAX(b.registered_at) AS production_updated_at,
           MAX(r.projected_at) AS wms_projection_updated_at
    FROM agri_demo.harvest_batch b
    LEFT JOIN agri_demo.receipt_projection r USING (batch_id)
    GROUP BY b.variety_id, b.season
)
SELECT a.variety_id, v.canonical_name, a.season, a.area_ha,
       COALESCE(f.harvested_t, 0) AS harvested_t,
       COALESCE(f.received_t, 0) AS received_t,
       COALESCE(f.harvested_t, 0) / NULLIF(a.area_ha, 0) AS yield_t_per_ha,
       f.received_batch_count::numeric / NULLIF(f.batch_count, 0) AS receipt_coverage,
       f.matched_delta_t,
       f.production_updated_at, f.wms_projection_updated_at
FROM area a
JOIN agri_demo.variety v USING (variety_id)
LEFT JOIN facts f USING (variety_id, season);
-- Freshness requires consumer watermark, not MAX(received_at) alone:
-- an old business event can arrive now; a quiet stream can still be current.
