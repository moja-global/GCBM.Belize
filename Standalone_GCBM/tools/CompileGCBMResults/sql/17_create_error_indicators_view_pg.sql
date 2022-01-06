CREATE UNLOGGED TABLE v_error_indicators{table_suffix} AS
SELECT
    CAST(l.year AS INTEGER) AS year,
    {classifiers_select},
    e.module AS module,
    e.error AS error,
    CAST(ROUND(CAST(SUM(l.area) AS NUMERIC), 6) AS REAL) AS area
FROM errordimension{table_suffix} e
LEFT JOIN locationerrordimension{table_suffix} le
    ON e.id = le.errordimid
LEFT JOIN r_location{table_suffix} l
    ON le.locationdimid = l.locationdimid
GROUP BY
   l.year,
   {classifiers_select},
   e.module,
   e.error;
