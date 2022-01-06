DROP TABLE IF EXISTS r_change_type_categories{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_pool_collections{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_pool_collection_pools{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_flux_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_flux_indicator_collections{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_flux_indicator_collection_flux_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_stock_changes{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_pool_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_location{table_suffix} CASCADE;
DROP TABLE IF EXISTS r_stand_area{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_disturbance_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_flux_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_age_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_error_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_flux_indicator_aggregates{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_pool_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_stock_change_indicators{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_total_disturbed_areas{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_flux_indicators_density{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_flux_indicator_aggregates_density{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_stock_change_indicators_density{table_suffix} CASCADE;
DROP TABLE IF EXISTS v_disturbance_fluxes{table_suffix} CASCADE;

CREATE UNLOGGED TABLE r_change_type_categories{table_suffix} (
    id SERIAL PRIMARY KEY,
    name VARCHAR);
    
CREATE UNLOGGED TABLE r_pool_collections{table_suffix} (
    id SERIAL PRIMARY KEY,
    description VARCHAR);

CREATE UNLOGGED TABLE r_pool_collection_pools{table_suffix} (
    pool_collection_id INT REFERENCES r_pool_collections{table_suffix} (id) NOT NULL,
    pool_id INT,
    PRIMARY KEY (pool_collection_id, pool_id));

CREATE UNLOGGED TABLE r_flux_indicators{table_suffix} (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    change_type_category_id INT REFERENCES r_change_type_categories{table_suffix} (id),
    source_pool_collection_id INT REFERENCES r_pool_collections{table_suffix} (id) NOT NULL,
    sink_pool_collection_id INT REFERENCES r_pool_collections{table_suffix} (id) NOT NULL);

CREATE UNLOGGED TABLE r_flux_indicator_collections{table_suffix} (
    id SERIAL PRIMARY KEY,
    description VARCHAR);

CREATE UNLOGGED TABLE r_flux_indicator_collection_flux_indicators{table_suffix} (
    flux_indicator_collection_id INT REFERENCES r_flux_indicator_collections{table_suffix} (id) NOT NULL,
    flux_indicator_id INT REFERENCES r_flux_indicators{table_suffix} (id) NOT NULL,
    PRIMARY KEY (flux_indicator_collection_id, flux_indicator_id));

CREATE UNLOGGED TABLE r_stock_changes{table_suffix} (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    flux_indicator_collection_id INT REFERENCES r_flux_indicator_collections{table_suffix} (id),
    add_sub INT NOT NULL);

CREATE UNLOGGED TABLE r_pool_indicators{table_suffix} (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    pool_collection_id INT REFERENCES r_pool_collections{table_suffix} (id));

CREATE UNLOGGED TABLE r_location{table_suffix} (
    locationdimid INTEGER,
    {ddl_classifiers},
    year INT,
    land_class VARCHAR,
    age_range VARCHAR,
    area DECIMAL,
    PRIMARY KEY (locationdimid)
);
