import logging
import os
import sqlite3
import sys
import pandas
from argparse import ArgumentParser

if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.INFO, format="%(message)s")
    parser = ArgumentParser(description="Modifying decay parameters")
    parser.add_argument("input_db_path", help="GCBM input database path", type=os.path.abspath)
    args = parser.parse_args()

    # set logger to write to file
    logger = logging.getLogger()
    handler = logging.FileHandler(os.path.join('logs', 'modify_turnover_parameters.log'))
    logger.addHandler(handler)
    
    if not os.path.exists(args.input_db_path):
        sys.exit("File not found: {}".format(args.input_db_path))
    
    with sqlite3.connect(args.input_db_path) as conn:
            
        logger.info("Modifying decay parameters")
        
        # Replace current decay parameters with new ones (tropical environment)
        df = pandas.read_csv("input_database/custom_parameters/turnover_parameters.csv")
        
        #Keep the column names that we need
        #df = df[['dom_pool_id', 'base_decay_rate', 'reference_temp','q10','prop_to_atmosphere','max_rate']]
        
        df.to_sql("turnover_parameter", conn, if_exists='replace', index=False)

        logger.info("Succesfully modified turnover parameters")
        
        logger.info("Done!")
