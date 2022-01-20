import logging
import os
import csv
import sqlite3
import sys
from argparse import ArgumentParser

if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.INFO, format="%(message)s")
    # argument: gcbm database
    parser = ArgumentParser(description="Create the deforestation Chile disturbance")
    parser.add_argument("input_db_path", help="GCBM input database path", type=os.path.abspath)
    args = parser.parse_args()

    if not os.path.exists(args.input_db_path):
        sys.exit("File not found: {}".format(args.input_db_path))

    with sqlite3.connect(args.input_db_path) as conn:
        cursor = conn.cursor()
        logging.info("Adding a generic tropical species")
        # Create a new species, I will call it "Generic Tropical", ID = 8001, Forest type = 3 (Hardwood) and Genus = 12 (Other broad-leaves species)

        with open('species.csv','r') as fin1: # `with` statement available in 2.5+
        # csv.DictReader uses first line in file for column headings by default
        dr1 = csv.DictReader(fin1) # comma is default delimiter
        to_db1 = [(i['id'], i['name'], i['forest_type_id'], i['genus_id']) for i in dr1]
        cursor.executemany(
            "INSERT INTO species (id, name, forest_type_id, genus_id)
            VALUES (?, ?, ?, ?)", to_db1
            )
        # My growth curves have a Red Alter in the species parameter, the id of the red alder is 118, I will replace it with my custom id (8001)
        with open('growth_curve_component.csv','r') as fin2: # `with` statement available in 2.5+
        # csv.DictReader uses first line in file for column headings by default
        dr2 = csv.DictReader(fin2) # comma is default delimiter
        to_db2 = [(i['species_id'], i['species_id']) for i in dr2]

        cursor.executemany(
            "UPDATE growth_curve_component
            SET species_id = ?
            WHERE species_id = ?", to_db2
            )
        # Associate the new species (id = 8001) to a vol to biomass set of values, the id of this association will be 801, insert this new association on the vol_to_bio_factor_association
        # Spatial unit = 36 (British Colombia and Pacific maritime

        with open('vol_to_bio_factor_association.csv','r') as fin3: # `with` statement available in 2.5+
        # csv.DictReader uses first line in file for column headings by default
        dr3 = csv.DictReader(fin3) # comma is default delimiter
        to_db3 = [(i['spatial_unit_id'], i['species_id'], i['vol_to_bio_factor_id'], i['root_parameter_id']) for i in dr3]

        cursor.executemany(
            "INSERT INTO vol_to_bio_factor_association (spatial_unit_id, species_id, vol_to_bio_factor_id,root_parameter_id)
            VALUES (?, ?, ?, ?)", to_db3
            )
        # Create a new set of vol to bio parameters
        # See Bowdewyn et al to knwo how to set the parameters of the vol to bio equations
        # we have 70% (0.75) stemwood and a density of 0.47, so our a factor is 0.329
        # non merchantable and sampling factors set to zero
        # 
        logging.info("Adding Vol to Bio parameters")
        with open('species.csv','r') as fin4: # `with` statement available in 2.5+
        # csv.DictReader uses first line in file for column headings by default
        dr4 = csv.reader(fin4) # comma is default delimiter

        cursor.executemany(
            "INSERT INTO vol_to_bio_factor
            SELECT 801 AS ?, 0.329 AS ?, 1 AS ?,
            0 AS ?, 1 AS ?, 1 AS ?, 1 AS ?,
            0 AS ?, 1 AS ?, 1 AS ?, 1 AS ?,
            -1.945910149 AS ?, 0 AS ?, 0 AS ?,
            -1.540445041 AS ?, 0 AS ?, 0 AS ?,
            -2.63905733 AS ?, 0 AS ?, 0 AS ?,
            0.1 AS ?, 1000000 AS ?,
            0.50249 AS ?, 0.70391 AS ?,
            0.09492 AS ?, 0.11402 AS ?,
            0.26098 AS ?, 0.14622 AS ?,
            0.1416 AS ?, 0.03585 AS ?", dr4
            )
        
