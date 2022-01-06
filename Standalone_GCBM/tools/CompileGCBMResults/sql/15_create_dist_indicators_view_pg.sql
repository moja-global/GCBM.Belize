CREATE UNLOGGED TABLE v_disturbance_indicators{table_suffix} AS
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
    CAST(ROUND(CAST(SUM(di.area) AS NUMERIC), 6) AS REAL) AS dist_area,
    CAST(ROUND(CAST(SUM(f.fluxvalue) AS NUMERIC), 6) AS REAL) AS dist_carbon
FROM (
    SELECT
        locationdimid,
        moduleinfodimid,
        disturbancedimid,
        SUM(fluxvalue) AS fluxvalue
    FROM fluxes{table_suffix}
    WHERE disturbancedimid IS NOT NULL
    GROUP BY
        locationdimid,
        moduleinfodimid,
        disturbancedimid
) AS f
INNER JOIN r_location{table_suffix} current
    ON f.locationdimid = current.locationdimid
INNER JOIN disturbancedimension{table_suffix} di
    ON f.disturbancedimid = di.id
INNER JOIN disturbancetypedimension{table_suffix} dt
    ON di.disturbancetypedimid = dt.id
INNER JOIN r_location{table_suffix} previous
    ON di.previouslocationdimid = previous.locationdimid
WHERE current.year > 0
GROUP BY
    {classifiers_select_current},
    {classifiers_select_previous},
    current.land_class,
    previous.land_class,
    dt.disturbancetype,
    dt.disturbancetypename,
    current.age_range,
    previous.age_range,
    current.year;