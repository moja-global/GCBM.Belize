CREATE TABLE {{indicator_table}}_density AS
SELECT
   total_flux.indicator,
   CAST(total_area.year AS INTEGER) AS year,
   CAST(COALESCE(total_flux.flux_tc, 0) AS REAL) AS flux_tc,
   CAST(COALESCE(total_flux.flux_tc / total_area.area, 0) AS REAL) AS flux_tc_per_ha
FROM (
   SELECT
       year,
       SUM(ai.area) AS area
    FROM v_age_indicators ai
    GROUP BY year
) AS total_area
LEFT JOIN (
    SELECT
        indicator,
        year,
        SUM(flux.flux_tc) AS flux_tc
    FROM {{indicator_table}} flux
    GROUP BY
        indicator,
        year
) AS total_flux
    ON total_area.year = total_flux.year
ORDER BY
    total_flux.indicator,
    total_flux.year
