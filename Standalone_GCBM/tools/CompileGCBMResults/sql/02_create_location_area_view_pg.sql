CREATE UNLOGGED TABLE r_stand_area{table_suffix} AS
SELECT
    {classifiers_select},
    d.year AS year,
    lc.name AS land_class,
    a.startage AS age_class_start,
    a.endage AS age_class_end,
    SUM(l.area) AS area
FROM locationdimension{table_suffix} l
INNER JOIN classifiersetdimension{table_suffix} c
    ON l.classifiersetdimid = c.id
INNER JOIN datedimension{table_suffix} d
    ON l.datedimid = d.id
INNER JOIN landclassdimension{table_suffix} lc
    ON l.landclassdimid = lc.id
INNER JOIN ageclassdimension{table_suffix} a
    ON l.ageclassdimid = a.id
GROUP BY
    {classifiers_select},
    d.year,
    lc.name,
    a.startage,
    a.endage;

INSERT INTO r_location{table_suffix}
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
FROM locationdimension{table_suffix} l
INNER JOIN classifiersetdimension{table_suffix} s
    ON l.classifiersetdimid = s.id
INNER JOIN datedimension{table_suffix} d
    ON l.datedimid = d.id
INNER JOIN landclassdimension{table_suffix} lc
    ON l.landclassdimid = lc.id
INNER JOIN ageclassdimension{table_suffix} ac
    ON l.ageclassdimid = ac.id
INNER JOIN r_stand_area{table_suffix} a
    ON {classifiers_join_s_a}
    AND d.year = a.year
    AND lc.name = a.land_class
    AND ac.startage = a.age_class_start
    AND ac.endage = a.age_class_end;

ANALYZE r_location{table_suffix};
