CREATE TABLE r_stand_area AS
SELECT
    {classifiers_select},
    d.year AS year,
    lc.name AS land_class,
    a.startage AS age_class_start,
    a.endage AS age_class_end,
    SUM(l.area) AS area
FROM locationdimension l
INNER JOIN classifiersetdimension c
    ON l.classifiersetdimid = c.id
INNER JOIN datedimension d
    ON l.datedimid = d.id
INNER JOIN landclassdimension lc
    ON l.landclassdimid = lc.id
INNER JOIN ageclassdimension a
    ON l.ageclassdimid = a.id
GROUP BY
    {classifiers_select},
    d.year,
    lc.name,
    a.startage,
    a.endage;

INSERT INTO r_location
SELECT
    l.id AS locationdimid,
    {classifiers_select_a},
    a.year,
    a.land_class,
    CASE
        WHEN a.age_class_start = -1 THEN 'N/A'
        WHEN a.age_class_end = -1 THEN a.age_class_start || '+'
        ELSE a.age_class_start || '-' || a.age_class_end
    END AS age_range,
    a.area
FROM locationdimension l
INNER JOIN classifiersetdimension s
    ON l.classifiersetdimid = s.id
INNER JOIN datedimension d
    ON l.datedimid = d.id
INNER JOIN landclassdimension lc
    ON l.landclassdimid = lc.id
INNER JOIN ageclassdimension ac
    ON l.ageclassdimid = ac.id
INNER JOIN r_stand_area a
    ON {classifiers_join_s_a}
    AND d.year = a.year
    AND lc.name = a.land_class
    AND ac.startage = a.age_class_start
    AND ac.endage = a.age_class_end;
