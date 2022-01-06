INSERT INTO r_pool_collection_pools{table_suffix} (pool_collection_id, pool_id)
SELECT
    pc.id AS pool_collection_id,
    p.id AS pool_id
FROM r_pool_collections{table_suffix} pc,
     pooldimension p
WHERE LOWER(pc.description) LIKE LOWER(:name)
    AND p.poolname IN ({{pools}})
