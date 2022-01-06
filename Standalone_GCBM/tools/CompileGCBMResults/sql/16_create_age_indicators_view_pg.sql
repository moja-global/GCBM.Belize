CREATE UNLOGGED TABLE v_age_indicators{table_suffix} AS
SELECT
   	CAST(l.year AS INTEGER) AS year,
  	{classifiers_select},
    l.land_class AS unfccc_land_class,
    l.age_range AS age_range,
   	CAST(ROUND(CAST(SUM(a.area) AS NUMERIC), 6) AS REAL) AS area
FROM agearea{table_suffix} a
INNER JOIN ageclassdimension{table_suffix} ac
    ON a.ageclassdimid = ac.id
INNER JOIN r_location{table_suffix} l
    ON a.locationdimid = l.locationdimid
WHERE l.year > 0
GROUP BY
   l.year,
   {classifiers_select},
   l.land_class,
   l.age_range;
