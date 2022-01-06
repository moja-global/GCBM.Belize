CREATE UNLOGGED TABLE v_flux_indicator_aggregates{table_suffix} AS
SELECT
    fic.id AS flux_indicator_collection_id,
    fic.description AS indicator,
    CAST(fi.year AS INTEGER) AS year,
    {classifiers_select},
    fi.unfccc_land_class AS unfccc_land_class,
    fi.age_range AS age_range,
    CAST(ROUND(CAST(SUM(fi.flux_tc) AS NUMERIC), 6) AS REAL) AS flux_tc
FROM r_flux_indicator_collections{table_suffix} fic
INNER JOIN r_flux_indicator_collection_flux_indicators{table_suffix} fic_fi
    ON fic.id = fic_fi.flux_indicator_collection_id
INNER JOIN v_flux_indicators{table_suffix} fi
    ON fic_fi.flux_indicator_id = fi.flux_indicator_id
GROUP BY
    fic.id,
    fic.description,
    fi.year,
    {classifiers_select},
    fi.unfccc_land_class,
    fi.age_range
