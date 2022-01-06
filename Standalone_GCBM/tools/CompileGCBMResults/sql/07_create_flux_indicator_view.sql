CREATE TABLE v_flux_indicators AS
SELECT
    fi.id AS flux_indicator_id,
    {classifiers_select},
    l.land_class AS unfccc_land_class,
    fi.name AS indicator,
    CAST(l.year AS INTEGER) AS year,
    dt.disturbancetype AS disturbance_code,
    dt.disturbancetypename AS disturbance_type,
    l.age_range AS age_range,
    CAST(
        SUM(CASE
                WHEN LOWER(ct.name) LIKE LOWER('Annual Process') AND f.disturbancedimid IS NULL THEN f.fluxvalue
                WHEN LOWER(ct.name) LIKE LOWER('Disturbance') AND f.disturbancedimid IS NOT NULL THEN f.fluxvalue
                WHEN LOWER(ct.name) LIKE LOWER('Combined') THEN f.fluxvalue
                ELSE 0
            END
        ) AS REAL
    ) AS flux_tc
FROM r_flux_indicators fi
INNER JOIN r_pool_collection_pools p_src
    ON fi.source_pool_collection_id = p_src.pool_collection_id
INNER JOIN r_pool_collection_pools p_dst
    ON fi.sink_pool_collection_id = p_dst.pool_collection_id
INNER JOIN fluxes f
    ON f.poolsrcdimid = p_src.pool_id
    AND f.pooldstdimid = p_dst.pool_id
INNER JOIN r_location l
    ON f.locationdimid = l.locationdimid
INNER JOIN r_change_type_categories ct
    ON fi.change_type_category_id = ct.id
LEFT JOIN disturbancedimension di
    ON f.disturbancedimid = di.id
LEFT JOIN disturbancetypedimension dt
    ON di.disturbancetypedimid = dt.id
GROUP BY
    fi.id,
    {classifiers_select},
    l.land_class,
    fi.name,
    dt.disturbancetype,
    dt.disturbancetypename,
    l.age_range,
    l.year
HAVING SUM(
    CASE
        WHEN LOWER(ct.name) LIKE LOWER('Annual Process') AND f.disturbancedimid IS NULL THEN f.fluxvalue
        WHEN LOWER(ct.name) LIKE LOWER('Disturbance') AND f.disturbancedimid IS NOT NULL THEN f.fluxvalue
        WHEN LOWER(ct.name) LIKE LOWER('Combined') THEN f.fluxvalue
        ELSE 0
    END
) > 0;