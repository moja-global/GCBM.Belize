import os
import simplejson as json
import logging
import sys
from string import Formatter
from itertools import zip_longest
from argparse import ArgumentParser
from sqlalchemy import create_engine
from sqlalchemy import text
from sqlalchemy import bindparam
from sqlalchemy import String
from sqlalchemy import MetaData
from sqlalchemy import Table
from sqlalchemy import select
from sqlalchemy import insert
from sqlalchemy import BLANK_SCHEMA

def load_sql(name, db_type, classifiers, batch=None):
    '''
    Loads SQL from a file, using the specialized version if available (i.e. 00_setup_pg.sql instead
    of 00_setup.sql for Postgres databases), and adds the simulation classifier columns in one of
    several different formats for queries that need them.
    '''
    logger.info(f"  {name}")
    sql_dir = os.path.join(os.path.dirname(__file__), "sql")
    for filename in (os.path.join(sql_dir, f"{name}_{db_type}.sql"),
                     os.path.join(sql_dir, f"{name}.sql")):
        if os.path.exists(filename):
            params = {"table_suffix": f"_{batch}" if batch else ""}
            queries = []
            for sql in open(filename, "r").read().split(";"):
                if sql and not sql.isspace():
                    sql_params = {key for _, key, _, _ in Formatter().parse(sql) if key}
                    for param in sql_params:
                        if "classifiers" not in param:
                            continue
                        
                        # Query can contain format strings to be replaced by classifier names:
                        # classifiers_select[_<table name>]
                        # classifiers_join_<table1>_<table2>
                        # classifiers_ddl
                        parts = param.split("_")
                        if "select" in parts:
                            table = parts[2] if len(parts) >= 3 else None
                            suffix = parts[3] if len(parts) == 4 else None
                            params[param] = ", ".join(
                                (f"{table}.{c} AS {c}_{suffix}" if suffix
                                    else f"{table}.{c}" for c in classifiers)
                                if table else classifiers)
                        elif "join" in parts:
                            _, _, lhs_table, rhs_table = parts
                            params[param] = " AND ".join((
                                (
                                    f"CASE WHEN ({lhs_table}.{c} = {rhs_table}.{c}) "
                                    f"OR ({lhs_table}.{c} IS NULL AND {rhs_table}.{c} IS NULL) "
                                    "THEN 0 ELSE 1 END = 0"
                                ) for c in classifiers))
                        elif "ddl" in parts:
                            params[param] = ", ".join((f"{c} VARCHAR" for c in classifiers))
                            
                    queries.append(sql.format(**params))
            
            return queries
    
    raise IOError(f"Couldn't find file for query '{name}'")
                
def find_project_classifiers(conn, batch=None):
    table_suffix = f"_{batch}" if batch else ""
    results = conn.execute(text(f"SELECT * FROM classifiersetdimension{table_suffix} LIMIT 1"))
    classifiers = [col for col in results.keys() if col.lower() not in ("id", "jobid")]
            
    return classifiers
        
def executemany(conn, queries, values):
    params = values[0].keys()
    for sql in queries:
        stmt = text(sql)
        stmt = stmt.bindparams(*[bindparam(param, type_=String) for param in params])
        conn.execute(stmt, values)
        
def compile_results(conn, db_type, indicators, batch=None, cleanup=False):
    logger.info("Compiling results tables...")

    # Get the classifier columns used by the simulation - varies by project.
    classifiers = find_project_classifiers(conn, batch)
    
    with conn.begin():
        for query in ("00_setup", "01_reporting_table_ddl", "02_create_location_area_view"):
            for sql in load_sql(query, db_type, classifiers, batch):
                conn.execute(text(sql))
        
        # Fluxes are the movement of carbon between pool collections as a result of
        # annual processes, disturbance, or both combined.
        sql = load_sql("03_populate_change_type_categories", db_type, classifiers, batch)
        executemany(conn, sql, [
            {"name": "Annual Process"},
            {"name": "Disturbance"},
            {"name": "Combined"}
        ])
        
        # Individual pools are grouped into named collections that are used to calculate fluxes.
        sql = load_sql("04_populate_pool_collections", db_type, classifiers, batch)
        executemany(conn, sql, [{"name": name} for name in indicators["pool_collections"]])
        
        sql = load_sql("05_populate_pool_collection_pools", db_type, classifiers, batch)[0]
        for name, pools in indicators["pool_collections"].items():
            params = {f"pool{i}": pool for i, pool in enumerate(pools)}
            pool_param_names = ", ".join((f":{param}" for param in params))
            conn.execute(text(sql.format(pools=pool_param_names)), name=name, **params)
        
        # A flux is a movement of carbon from any pool in the source collection to any pool in the
        # sink collection as a result of annual processes, disturbances, or both combined.
        sql = load_sql("06_populate_flux_indicators", db_type, classifiers, batch)
        executemany(conn, sql, [{
                "name"       : name,
                "change_type": details["source"],
                "source"     : details["from"],
                "sink"       : details["to"]}
            for name, details in indicators["fluxes"].items()
        ])
        
        sql = load_sql("07_create_flux_indicator_view", db_type, classifiers, batch)[0]
        conn.execute(text(sql))
        
        # Fluxes are grouped into named collections that are used as indicators themselves, and also
        # to calculate stock change indicators where fluxes are added or subtracted from each other.
        sql = load_sql("08_populate_flux_indicator_collections", db_type, classifiers, batch)
        executemany(conn, sql, [{"name": name} for name in indicators["flux_collections"]])
        
        sql = load_sql("09_populate_flux_indicator_collection_flux_indicators", db_type, classifiers, batch)[0]
        for name, fluxes in indicators["flux_collections"].items():
            params = {f"flux{i}": flux for i, flux in enumerate(fluxes)}
            flux_param_names = ", ".join((f":{param}" for param in params))
            conn.execute(text(sql.format(fluxes=flux_param_names)), name=name, **params)
        
        # Stock change indicators are groups of fluxes that are added or subtracted from each other.
        sql = load_sql("10_populate_stock_changes", db_type, classifiers, batch)[0]
        for name, details in indicators["stock_changes"].items():
            add_flux_params = {f"add_flux{i}": flux for i, flux in enumerate(details.get("+") or ["_"])}
            add_flux_param_names = ", ".join((f":{param}" for param in add_flux_params))
            sub_flux_params = {f"sub_flux{i}": flux for i, flux in enumerate(details.get("-") or ["_"])}
            sub_flux_param_names = ", ".join((f":{param}" for param in sub_flux_params))
            
            params = {}
            params.update(add_flux_params)
            params.update(sub_flux_params)
            
            conn.execute(
                text(sql.format(add_fluxes=add_flux_param_names, subtract_fluxes=sub_flux_param_names)),
                name=name, **params)
                
        for query in ("11_create_flux_indicator_aggregates_view", "12_create_stock_change_indicators_view"):
            for sql in load_sql(query, db_type, classifiers, batch):
                conn.execute(text(sql))
        
        # Pool indicators report on named collections of pools.
        sql = load_sql("13_populate_pool_indicators", db_type, classifiers, batch)
        executemany(conn, sql, [{"name": name, "pools": pools}
                                for name, pools in indicators["pool_indicators"].items()])
        
        for query in ("14_create_pool_indicators_view", "15_create_dist_indicators_view",
                      "16_create_age_indicators_view", "17_create_error_indicators_view",
                      "18_create_total_disturbed_areas_view", "20_create_disturbance_fluxes_view"):
            for sql in load_sql(query, db_type, classifiers, batch):
                conn.execute(text(sql))
                
        density_sql = load_sql("19_create_density_views", db_type, classifiers, batch)
        if density_sql:
            sql = density_sql[0]
            for table in ("v_flux_indicators", "v_flux_indicator_aggregates", "v_stock_change_indicators"):
                conn.execute(text(sql.format(indicator_table=table)))
                
        if cleanup:
            table_suffix = f"_{batch}" if batch else ""
            for sql in [
                "DROP TABLE IF EXISTS agearea{} CASCADE;",
                "DROP TABLE IF EXISTS ageclassdimension{} CASCADE;",
                "DROP TABLE IF EXISTS classifiersetdimension{} CASCADE;",
                "DROP TABLE IF EXISTS datedimension{} CASCADE;",
                "DROP TABLE IF EXISTS disturbancedimension{} CASCADE;",
                "DROP TABLE IF EXISTS disturbancetypedimension{} CASCADE;",
                "DROP TABLE IF EXISTS errordimension{} CASCADE;",
                "DROP TABLE IF EXISTS fluxes{} CASCADE;",
                "DROP TABLE IF EXISTS landclassdimension{} CASCADE;",
                "DROP TABLE IF EXISTS locationdimension{} CASCADE;",
                "DROP TABLE IF EXISTS locationerrordimension{} CASCADE;",
                "DROP TABLE IF EXISTS moduleinfodimension{} CASCADE;",
                "DROP TABLE IF EXISTS pools{} CASCADE;",
                "DROP TABLE IF EXISTS r_change_type_categories{} CASCADE;",
                "DROP TABLE IF EXISTS r_pool_collections{} CASCADE;",
                "DROP TABLE IF EXISTS r_pool_collection_pools{} CASCADE;",
                "DROP TABLE IF EXISTS r_flux_indicators{} CASCADE;",
                "DROP TABLE IF EXISTS r_flux_indicator_collections{} CASCADE;",
                "DROP TABLE IF EXISTS r_flux_indicator_collection_flux_indicators{} CASCADE;",
                "DROP TABLE IF EXISTS r_stock_changes{} CASCADE;",
                "DROP TABLE IF EXISTS r_pool_indicators{} CASCADE;",
                "DROP TABLE IF EXISTS r_location{} CASCADE;",
                "DROP TABLE IF EXISTS r_stand_area{} CASCADE;",
            ]:
                conn.execute(text(sql.format(table_suffix)))
                
def copy_reporting_tables(from_conn, from_schema, to_conn, to_schema=None):
    logger.info("Copying reporting tables to output database...")
    md = MetaData()
    md.reflect(bind=from_conn, schema=from_schema, views=True,
               only=lambda table_name, _: table_name.startswith("v_"))
               
    output_md = MetaData(bind=to_conn, schema=to_schema)
    with to_conn.begin():
        for fqn, table in md.tables.items():
            logger.info(f"  {fqn}")
            table.tometadata(output_md, schema=None)
            
            output_table = Table(table.name, output_md)
            output_table.drop(checkfirst=True)
            output_table.create()
            
            batch = []
            for i, row in enumerate(from_conn.execute(select([table]))):
                batch.append({k: v for k, v in row.items()})
                if i % 10000 == 0:
                    to_conn.execute(insert(output_table), batch)
                    batch = []
            
            if batch:
                to_conn.execute(insert(output_table), batch)
        
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, stream=sys.stdout, format="%(asctime)s %(message)s",
                        datefmt="%m/%d %H:%M:%S")
    
     # set logger to write to file
    logger = logging.getLogger()
    handler = logging.FileHandler(os.path.join('..','..','logs', 'compile_results.log'))
    logger.addHandler(handler)

    parser = ArgumentParser(description="Produce reporting tables from raw GCBM results. For connection strings, "
                                        "see https://docs.sqlalchemy.org/en/latest/core/engines.html#database-urls")

    parser.add_argument("results_db",         help="connection string for the simulation results database")
    parser.add_argument("--results_schema",   help="name of the schema containing the simulation results", type=str.lower)
    parser.add_argument("--output_db",        help="connection string for the database to copy final reporting tables to")
    parser.add_argument("--output_schema",    help="name of the schema to copy final reporting tables to", type=str.lower)
    parser.add_argument("--indicator_config", help="indicator configuration file - defaults to a generic set")
    args = parser.parse_args()
    
    results_db_engine = create_engine(args.results_db)
    conn = results_db_engine.connect()
    if args.results_schema:
        conn.execute(text(f"SET SEARCH_PATH={args.results_schema}"))
    
    # Some queries are specialized for distributed runs using Postgres; these are the
    # files with the _pg suffix in sql\.
    db_type = "pg" if args.results_db.startswith("postgres") else ""

    indicators = json.load(open(
        args.indicator_config
        or os.path.join(os.path.dirname(__file__), "compileresults.json")))
    
    compile_results(conn, db_type, indicators)
    if args.output_db:
        output_db_engine = create_engine(args.output_db)
        output_conn = output_db_engine.connect()
        if args.output_schema:
            output_conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {args.output_schema}"))
            
        copy_reporting_tables(conn, args.results_schema, output_conn, args.output_schema)
