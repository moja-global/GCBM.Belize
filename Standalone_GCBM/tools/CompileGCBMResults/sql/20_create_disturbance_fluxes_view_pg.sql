CREATE UNLOGGED TABLE v_disturbance_fluxes{table_suffix} AS
SELECT
    {classifiers_select_current},
    {classifiers_select_previous_previous},
    current.land_class AS unfccc_land_class,
    previous.land_class AS unfccc_land_class_previous,
    CAST(current.year AS INTEGER) AS year,
    dt.disturbancetype AS disturbance_code,
    dt.disturbancetypename AS disturbance_type,
    previous.age_range AS pre_dist_age_range,
    current.age_range AS post_dist_age_range,
    src.poolname AS from_pool,
    dst.poolname AS to_pool,
    CAST(ROUND(CAST(SUM(f.fluxvalue) AS NUMERIC), 6) AS REAL) AS flux_tc
FROM fluxes{table_suffix} f
INNER JOIN pooldimension src
    ON f.poolsrcdimid = src.id
INNER JOIN pooldimension dst
    ON f.pooldstdimid = dst.id
INNER JOIN disturbancedimension{table_suffix} di
    ON f.disturbancedimid = di.id
INNER JOIN r_location{table_suffix} current
    ON f.locationdimid = current.locationdimid
INNER JOIN r_location{table_suffix} previous
    ON di.previouslocationdimid = previous.locationdimid
INNER JOIN disturbancetypedimension{table_suffix} dt
    ON di.disturbancetypedimid = dt.id
WHERE current.year > 0
GROUP BY
    src.poolname,
    dst.poolname,
    {classifiers_select_current},
    {classifiers_select_previous},
    current.land_class,
    previous.land_class,
    dt.disturbancetype,
    dt.disturbancetypename,
    current.age_range,
    previous.age_range,
    current.year;