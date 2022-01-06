INSERT INTO r_flux_indicators{table_suffix} (
    name,
    change_type_category_id,
    source_pool_collection_id,
    sink_pool_collection_id)
SELECT
    :name AS name,
    ct.id AS change_type_category_id,
    src.id AS source_pool_collection_id,
    snk.id AS sink_pool_collection_id
FROM r_change_type_categories{table_suffix} ct,
     r_pool_collections{table_suffix} src,
     r_pool_collections{table_suffix} snk
WHERE LOWER(ct.name) LIKE LOWER(:change_type)
    AND LOWER(src.description) LIKE LOWER(:source)
    AND LOWER(snk.description) LIKE LOWER(:sink)
