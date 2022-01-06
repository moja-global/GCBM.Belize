CREATE UNLOGGED TABLE v_pool_indicators{table_suffix} AS
SELECT
    pid.id AS indicator_id,
    {classifiers_select},
    l.land_class AS unfccc_land_class,
    pid.name AS indicator,
    CAST(l.year AS INTEGER) AS year,
    l.age_range AS age_range,
    CAST(ROUND(CAST(SUM(p.poolvalue) AS NUMERIC), 6) AS REAL) AS pool_tc
FROM r_pool_indicators{table_suffix} pid
INNER JOIN r_pool_collection_pools{table_suffix} pcp
    ON pid.pool_collection_id = pcp.pool_collection_id
INNER JOIN pools{table_suffix} p
    ON pcp.pool_id = p.poolid
INNER JOIN r_location{table_suffix} l
    ON p.locationdimid = l.locationdimid
WHERE l.year > 0
GROUP BY
    pid.id,
    pid.name,
    l.year,
    l.age_range,
    {classifiers_select},
    l.land_class;
