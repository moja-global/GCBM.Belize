DROP TABLE IF EXISTS r_change_type_categories;
DROP TABLE IF EXISTS r_pool_collections;
DROP TABLE IF EXISTS r_pool_collection_pools;
DROP TABLE IF EXISTS r_flux_indicators;
DROP TABLE IF EXISTS r_flux_indicator_collections;
DROP TABLE IF EXISTS r_flux_indicator_collection_flux_indicators;
DROP TABLE IF EXISTS r_stock_changes;
DROP TABLE IF EXISTS r_pool_indicators;
DROP TABLE IF EXISTS r_location;
DROP TABLE IF EXISTS r_stand_area;
DROP TABLE IF EXISTS v_disturbance_indicators;
DROP TABLE IF EXISTS v_flux_indicators;
DROP TABLE IF EXISTS v_age_indicators;
DROP TABLE IF EXISTS v_error_indicators;
DROP TABLE IF EXISTS v_flux_indicator_aggregates;
DROP TABLE IF EXISTS v_pool_indicators;
DROP TABLE IF EXISTS v_stock_change_indicators;
DROP TABLE IF EXISTS v_total_disturbed_areas;
DROP TABLE IF EXISTS v_flux_indicators_density;
DROP TABLE IF EXISTS v_flux_indicator_aggregates_density;
DROP TABLE IF EXISTS v_stock_change_indicators_density;
DROP TABLE IF EXISTS v_disturbance_fluxes;

CREATE TABLE r_change_type_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR);

CREATE TABLE r_pool_collections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description VARCHAR);

CREATE TABLE r_pool_collection_pools (
    pool_collection_id INTEGER REFERENCES r_pool_collections (id) NOT NULL,
    pool_id UNSIGNED BIG INT REFERENCES PoolDimension (id) NOT NULL,
    PRIMARY KEY (pool_collection_id, pool_id));

CREATE TABLE r_flux_indicators (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    change_type_category_id INTEGER REFERENCES r_change_type_categories (id),
    source_pool_collection_id INTEGER REFERENCES r_pool_collections (id) NOT NULL,
    sink_pool_collection_id INTEGER REFERENCES r_pool_collections (id) NOT NULL);

CREATE TABLE r_flux_indicator_collections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description VARCHAR);

CREATE TABLE r_flux_indicator_collection_flux_indicators (
    flux_indicator_collection_id INTEGER REFERENCES r_flux_indicator_collections (id) NOT NULL,
    flux_indicator_id INTEGER REFERENCES r_flux_indicators (id) NOT NULL,
    PRIMARY KEY (flux_indicator_collection_id, flux_indicator_id));

CREATE TABLE r_stock_changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    flux_indicator_collection_id INTEGER REFERENCES r_flux_indicator_collections (id),
    add_sub INTEGER NOT NULL);

CREATE TABLE r_pool_indicators (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    pool_collection_id INTEGER REFERENCES r_pool_collections (id));

CREATE TABLE r_location (
    locationdimid INTEGER PRIMARY KEY REFERENCES locationdimension (id) NOT NULL,
    {ddl_classifiers},
    year INT,
    land_class VARCHAR,
    age_range VARCHAR,
    area DECIMAL
);
