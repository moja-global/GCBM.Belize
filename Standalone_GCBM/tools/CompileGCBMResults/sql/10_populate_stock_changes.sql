INSERT INTO r_stock_changes{table_suffix} (name, flux_indicator_collection_id, add_sub)
SELECT :name AS name, fic.id AS flux_indicator_collection_id, 1 AS add_sub
FROM r_flux_indicator_collections{table_suffix} fic
WHERE fic.description IN ({{add_fluxes}})
UNION
SELECT :name AS name, fic.id AS flux_indicator_collection_id, -1 AS add_sub
FROM r_flux_indicator_collections{table_suffix} fic
WHERE fic.description IN ({{subtract_fluxes}})
