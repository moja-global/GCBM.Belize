CREATE TABLE v_stock_change_indicators AS
SELECT
    sc.name AS indicator,
    {classifiers_select},
    f.unfccc_land_class AS unfccc_land_class,
    CAST(f.year AS INTEGER) AS year,
    f.age_range AS age_range,
    CAST(SUM(f.flux_tc * sc.add_sub) AS REAL) AS flux_tc
FROM r_stock_changes sc
INNER JOIN v_flux_indicator_aggregates f
    ON sc.flux_indicator_collection_id = f.flux_indicator_collection_id
GROUP BY
    sc.name,
    {classifiers_select},
    f.unfccc_land_class,
    f.age_range,
    f.year