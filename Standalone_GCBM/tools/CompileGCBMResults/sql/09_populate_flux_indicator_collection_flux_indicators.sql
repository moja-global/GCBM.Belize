INSERT INTO r_flux_indicator_collection_flux_indicators{table_suffix} (flux_indicator_collection_id, flux_indicator_id)
SELECT fic.id AS flux_indicator_collection_id, fi.id AS flux_indicator_id
FROM r_flux_indicator_collections{table_suffix} fic, r_flux_indicators{table_suffix} fi
WHERE LOWER(fic.description) LIKE LOWER(:name)
    AND fi.name IN ({{fluxes}})
