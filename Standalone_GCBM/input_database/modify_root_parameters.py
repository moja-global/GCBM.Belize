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
    
    if not os.path.exists(args.input_db_path):
        sys.exit("File not found: {}".format(args.input_db_path))
    
    with sqlite3.connect(args.input_db_path) as conn:
        cursor = conn.cursor()    
        logging.info("Modifying the root parameters")
        # Modify the root parameters for Belize, the last 3 parameters are left as default
         with open('root_parameter.csv','r') as fin1: # `with` statement available in 2.5+
        # csv.DictReader uses first line in file for column headings by default
        dr1 = csv.DictReader(fin1) # comma is default delimiter
        to_db1 = [(i['hw_a'], i['sw_a'], i['hw_b'], i['frp_a'], i['frp_b'], i['frp_c'], i['id']) for i in dr1]
        cursor.executemany("UPDATE root_parameter SET hw_a = ?, sw_a = ?, hw_b = ?, frp_a = ?, frp_b = ?, frp_c = ? WHERE id = ?, to_db1)
        logging.info("Done!")
        
        
