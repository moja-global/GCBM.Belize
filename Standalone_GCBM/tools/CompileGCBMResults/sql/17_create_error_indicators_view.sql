CREATE TABLE v_error_indicators AS
SELECT
   	CAST(l.year AS INTEGER) AS year,
  	{classifiers_select},
    e.module AS module,
    e.error AS error,
    CAST(SUM(l.area) AS REAL) AS area
FROM errordimension e
LEFT JOIN locationerrordimension le
    ON e.id = le.errordimid
LEFT JOIN r_location l
    ON le.locationdimid = l.locationdimid
GROUP BY
   l.year,
   {classifiers_select},
   e.module,
   e.error;
