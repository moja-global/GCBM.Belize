INSERT INTO r_pool_indicators{table_suffix} (name, pool_collection_id)
SELECT :name AS name, pc.id AS pool_collection_id
FROM r_pool_collections{table_suffix} pc
WHERE LOWER(pc.description) LIKE LOWER(:pools)
