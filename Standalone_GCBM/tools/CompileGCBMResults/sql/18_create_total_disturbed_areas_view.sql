CREATE TABLE v_total_disturbed_areas AS
SELECT
    {classifiers_select_current},
    {classifiers_select_previous_previous},
    current.land_class AS unfccc_land_class,
    previous.land_class AS unfccc_land_class_previous,
    CAST(current.year AS INTEGER) AS year,
    dt.disturbancetype AS disturbance_code,
    dt.disturbancetypename AS disturbance_type,
    CAST(SUM(di.area) AS REAL) AS dist_area
FROM disturbancedimension di
INNER JOIN r_location current
    ON di.locationdimid = current.locationdimid
INNER JOIN r_location previous
    ON di.previouslocationdimid = previous.locationdimid
INNER JOIN disturbancetypedimension dt
    ON di.disturbancetypedimid = dt.id
GROUP BY
    {classifiers_select_current},
    {classifiers_select_previous},
    current.land_class,
    previous.land_class,
    dt.disturbancetype,
    dt.disturbancetypename,
    current.year;