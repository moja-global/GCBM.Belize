import logging
import os
import sqlite3
import sys
from argparse import ArgumentParser

if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.INFO, format="%(message)s")
    # argument: gcbm database
    parser = ArgumentParser(description="Change the spinup parameters")
    parser.add_argument("input_db_path", help="GCBM input database path", type=os.path.abspath)
    args = parser.parse_args()
    
    if not os.path.exists(args.input_db_path):
        sys.exit("File not found: {}".format(args.input_db_path))
    
    with sqlite3.connect(args.input_db_path) as conn:
            
        
        logging.info("Changing the spinup parameters")

        # 
        conn.execute(
            """
            UPDATE spatial_unit
            SET spinup_parameter_id = 7001
            WHERE id IN (36)
            """)
            
            
        # 
        conn.execute(
            """
            INSERT INTO spinup_parameter (id, historic_disturbance_type_id, return_interval, max_rotations, mean_annual_temperature)
            VALUES (7001, 49, 10, 500, 25)
            """)
