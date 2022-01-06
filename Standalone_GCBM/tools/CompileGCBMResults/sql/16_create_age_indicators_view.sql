CREATE TABLE v_age_indicators AS
SELECT
   	CAST(l.year AS INTEGER) AS year,
  	{classifiers_select},
    l.land_class AS unfccc_land_class,
    l.age_range AS age_range,
   	CAST(SUM(a.area) AS REAL) AS area
FROM agearea a
INNER JOIN ageclassdimension ac
    ON a.ageclassdimid = ac.id
INNER JOIN r_location l
    ON a.locationdimid = l.locationdimid
WHERE l.year > 0
GROUP BY
   l.year,
   {classifiers_select},
   l.land_class,
   l.age_range;
