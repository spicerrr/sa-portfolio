-- Выполнить после 01_schema.sql, 02_passport.sql и 03_demo.sql.
-- Дополнительные записи существуют только внутри транзакции проверки.
BEGIN;
SET LOCAL search_path TO agri_demo;
CREATE TEMP TABLE passport_checks (check_name text PRIMARY KEY);

DO $checks$
DECLARE
    p record;
    n numeric;
BEGIN
    SELECT * INTO STRICT p FROM variety_passport
      WHERE variety_id = 'VAR-017' AND season = 2026;
    IF p.harvested_t IS DISTINCT FROM 15::numeric
       OR p.area_ha IS DISTINCT FROM 5::numeric
       OR p.yield_t_per_ha IS DISTINCT FROM 3::numeric
       OR p.received_t IS DISTINCT FROM 8.370::numeric
       OR p.receipt_coverage IS DISTINCT FROM (1::numeric / 3)
       OR p.matched_delta_t IS DISTINCT FROM (-0.050::numeric) THEN
        RAISE EXCEPTION 'Неверные показатели исходного набора: %', row_to_json(p);
    END IF;
    INSERT INTO passport_checks VALUES ('01. Показатели исходного набора');

    SELECT SUM(b.weight_kg) / 1000 INTO n
      FROM harvest_batch b
      LEFT JOIN receipt_projection r USING (batch_id)
      WHERE r.batch_id IS NULL;
    IF n IS DISTINCT FROM 6.580::numeric THEN
        RAISE EXCEPTION 'Неверная масса партий без подтверждения: %', n;
    END IF;
    INSERT INTO passport_checks VALUES ('02. Без подтверждения — 6,580 т');

    SELECT SUM(s.bearing_area_ha) INTO n
      FROM plot_season s JOIN harvest_batch b
        USING (plot_id, season, variety_id);
    IF n IS DISTINCT FROM 7::numeric OR p.area_ha IS DISTINCT FROM 5::numeric THEN
        RAISE EXCEPTION 'Контроль повторения площади не выполнен';
    END IF;
    INSERT INTO passport_checks VALUES ('03. Площадь не повторяется по числу сборов');

    INSERT INTO plot VALUES ('TEST-NO-HARVEST', 'Контроль: участок без сбора');
    INSERT INTO plot_season VALUES ('TEST-NO-HARVEST', 2026, 'VAR-017', 1);
    SELECT * INTO STRICT p FROM variety_passport
      WHERE variety_id = 'VAR-017' AND season = 2026;
    IF p.area_ha IS DISTINCT FROM 6::numeric
       OR p.yield_t_per_ha IS DISTINCT FROM 2.5::numeric THEN
        RAISE EXCEPTION 'Участок без сбора потерян из площади';
    END IF;
    INSERT INTO passport_checks VALUES ('04. Участок без сбора входит в площадь');

    INSERT INTO variety VALUES ('TEST-VARIETY', 'Контрольный сорт', true);
    INSERT INTO plot VALUES ('TEST-OTHER-VARIETY', 'Контроль: другой сорт');
    INSERT INTO plot_season VALUES ('TEST-OTHER-VARIETY', 2026, 'TEST-VARIETY', 4);
    INSERT INTO harvest_batch
      (batch_id, plot_id, season, variety_id, source_system, source_record_id, harvest_date, weight_kg)
      VALUES ('TEST-BATCH', 'TEST-OTHER-VARIETY', 2026, 'TEST-VARIETY',
              'TEST', 'TEST-ROW', '2026-08-20', 2000);
    SELECT * INTO STRICT p FROM variety_passport
      WHERE variety_id = 'TEST-VARIETY' AND season = 2026;
    IF p.harvested_t IS DISTINCT FROM 2::numeric
       OR p.yield_t_per_ha IS DISTINCT FROM 0.5::numeric THEN
        RAISE EXCEPTION 'Неверный расчёт другого сорта';
    END IF;
    SELECT harvested_t INTO STRICT n FROM variety_passport
      WHERE variety_id = 'VAR-017' AND season = 2026;
    IF n IS DISTINCT FROM 15::numeric THEN
        RAISE EXCEPTION 'Смешаны данные разных сортов';
    END IF;
    INSERT INTO passport_checks VALUES ('05. Сорта рассчитываются отдельно');

    INSERT INTO plot_season VALUES ('PLOT-044', 2025, 'VAR-017', 10);
    SELECT * INTO STRICT p FROM variety_passport
      WHERE variety_id = 'VAR-017' AND season = 2025;
    IF p.area_ha IS DISTINCT FROM 10::numeric
       OR p.harvested_t IS DISTINCT FROM 0::numeric
       OR p.yield_t_per_ha IS DISTINCT FROM 0::numeric
       OR p.receipt_coverage IS NOT NULL OR p.matched_delta_t IS NOT NULL THEN
        RAISE EXCEPTION 'Неверный результат сезона без сборов';
    END IF;
    SELECT area_ha INTO STRICT n FROM variety_passport
      WHERE variety_id = 'VAR-017' AND season = 2026;
    IF n IS DISTINCT FROM 6::numeric THEN
        RAISE EXCEPTION 'Смешаны площади разных сезонов';
    END IF;
    INSERT INTO passport_checks VALUES ('06. Сезоны разделены; без сборов полнота не определена');

    BEGIN
        INSERT INTO harvest_batch
          (batch_id, plot_id, season, variety_id, source_system, source_record_id, harvest_date, weight_kg)
          VALUES ('TEST-DUP', 'PLOT-044', 2026, 'VAR-017',
                  'PRODUCTION', 'SRC-1284', '2026-08-14', 8420);
        RAISE EXCEPTION 'БД допустила повтор исходной строки';
    EXCEPTION WHEN unique_violation THEN
        INSERT INTO passport_checks VALUES ('07. Повтор исходной строки отклоняется');
    END;

    BEGIN
        INSERT INTO harvest_batch
          (batch_id, plot_id, season, variety_id, source_system, source_record_id, harvest_date, weight_kg)
          VALUES ('TEST-WRONG-VARIETY', 'PLOT-044', 2026, 'TEST-VARIETY',
                  'TEST', 'WRONG-VARIETY', '2026-08-14', 100);
        RAISE EXCEPTION 'БД допустила сорт, не соответствующий посадке';
    EXCEPTION WHEN foreign_key_violation THEN
        INSERT INTO passport_checks VALUES ('08. Сорт сбора соответствует посадке');
    END;

    INSERT INTO plot VALUES ('TEST-ZERO-AREA', 'Контроль: неверная площадь');
    BEGIN
        INSERT INTO plot_season VALUES ('TEST-ZERO-AREA', 2026, 'VAR-017', 0);
        RAISE EXCEPTION 'БД допустила нулевую площадь';
    EXCEPTION WHEN check_violation THEN
        INSERT INTO passport_checks VALUES ('09. Нулевая площадь отклоняется');
    END;
END
$checks$;

SELECT check_name, 'Пройдено' AS result FROM passport_checks ORDER BY check_name;
ROLLBACK;
