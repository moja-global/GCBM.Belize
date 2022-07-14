import logging
import os
import sqlite3
import sys
from argparse import ArgumentParser

if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.INFO, format="%(message)s")
    parser = ArgumentParser(description="Modify the root parameter")
    parser.add_argument("input_db_path", help="GCBM input database path", type=os.path.abspath)
    args = parser.parse_args()

    # Setup logger to write to file
    logger = logging.getLogger()
    handler = logging.FileHandler(os.path.join('logs', 'modify_root_parameters.log'))
    logger.addHandler(handler)
    
    if not os.path.exists(args.input_db_path):
        sys.exit("File not found: {}".format(args.input_db_path))
    
    with sqlite3.connect(args.input_db_path) as conn:
            
        logger.info("Modifying the root parameters")
        # Modify the root parameters for Belize, the last 3 parameters are left as default
        conn.execute(
            """
            UPDATE root_parameter
            SET hw_a = 0.37, sw_a = 0.37, hw_b = 1, frp_a = 0.072, frp_b = 0.354, frp_c = -0.060211946105009635
            WHERE id = 1
            """)
        logger.info("Done!")
        
        