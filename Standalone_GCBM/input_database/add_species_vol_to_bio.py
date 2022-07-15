from asyncio.log import logger
from cmath import log
import logging
import os
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
    
    logger = logging.getLogger()
    handler = logging.FileHandler(os.path.join('logs', 'add_species_vol_to_bio.log'))
    logger.addHandler(handler)

    with sqlite3.connect(args.input_db_path) as conn:
        
        logger.info("Adding a generic tropical species")
        # Create a new species, I will call it "Generic Tropical", ID = 8001, Forest type = 3 (Hardwood) and Genus = 12 (Other broad-leaves species)
        conn.execute(
            """
            INSERT INTO species (id, name, forest_type_id, genus_id)
            VALUES (8001, 'Generic Tropical', 3, 12)
            """)
        # My growth curves have a Red Alter in the species parameter, the id of the red alder is 118, I will replace it with my custom id (8001)
        conn.execute(
            """
            UPDATE growth_curve_component
            SET species_id = 8001
            WHERE species_id IN (118)
            """)
        # Associate the new species (id = 8001) to a vol to biomass set of values, the id of this association will be 801, insert this new association on the vol_to_bio_factor_association
        # Spatial unit = 36 (British Colombia and Pacific maritime
        conn.execute(
            """
            INSERT INTO vol_to_bio_factor_association (spatial_unit_id, species_id, vol_to_bio_factor_id,root_parameter_id)
            VALUES (36, 8001, 801,1)
            """)
        # Create a new set of vol to bio parameters
        # See Bowdewyn et al to knwo how to set the parameters of the vol to bio equations
        # we have 70% (0.75) stemwood and a density of 0.47, so our a factor is 0.329
        # non merchantable and sampling factors set to zero
        # 
        logger.info("Adding Vol to Bio parameters")
        conn.execute(
            """
            INSERT INTO vol_to_bio_factor
            SELECT 801 AS id, 0.329 AS a, 1 AS b,
            0 AS a_nonmerch, 1 AS b_nonmerch, 1 AS k_nonmerch, 1 AS cap_nonmerch,
            0 AS a_sap, 1 AS b_sap, 1 AS k_sap, 1 AS cap_sap,
            -1.945910149 AS a1, 0 AS a2, 0 AS a3,
            -1.540445041 AS b1, 0 AS b2, 0 AS b3,
            -2.63905733 AS c1, 0 AS c2, 0 AS c3,
            0.1 AS min_volume, 1000000 AS max_volume,
            0.50249 AS low_stemwood_pop, 0.70391 AS high_stemwood_pop,
            0.09492 AS low_stembark_prop, 0.11402 AS high_stembark_prop,
            0.26098 AS low_branches_prop, 0.14622 AS high_branches_pop,
            0.1416 AS low_foliage_prop, 0.03585 AS high_foliage_prop
            """)
        