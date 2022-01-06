import os
import logging
import sys
from glob import glob
from collections import OrderedDict
from mojadata.boundingbox import BoundingBox
from mojadata.cleanup import cleanup
from mojadata.gdaltiler2d import GdalTiler2D
from mojadata.compressingtiler3d import CompressingTiler3D
from mojadata.layer.vectorlayer import VectorLayer
from mojadata.layer.rasterlayer import RasterLayer
from mojadata.layer.gcbm.disturbancelayer import DisturbanceLayer
from mojadata.layer.regularstacklayer import RegularStackLayer
from mojadata.layer.attribute import Attribute
from mojadata.layer.gcbm.transitionrule import TransitionRule
from mojadata.layer.gcbm.transitionrulemanager import SharedTransitionRuleManager
from mojadata.layer.filter.valuefilter import ValueFilter
from mojadata.util import gdal
from mojadata.util.gdalhelper import GDALHelper

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, filename=r"..\..\logs\tiler_log.txt", filemode="w",
                        format="%(asctime)s %(message)s", datefmt="%m/%d %H:%M:%S")

    mgr = SharedTransitionRuleManager()
    mgr.start()
    rule_manager = mgr.TransitionRuleManager()
   
    with cleanup():
        # Input layer path relative to where the script is being run from; assuming layers\tiled.
        layer_root = os.path.join("..", "raw")

        '''
        Define the bounding box of the simulation - all layers will be reprojected, cropped, and
        resampled to the bounding box area. The bounding box layer can be filtered by an attribute
        value to simulate a specific area.
        '''
        bbox = BoundingBox(
            VectorLayer(
                "bbox",
                os.path.join(layer_root, "inventory", "inventory.shp"),
                Attribute("Id")),
            pixel_size=0.001)
                    
        tiler = GdalTiler2D(bbox, use_bounding_box_resolution=True)

        '''
        Classifier layers link pixels to yield curves.
          - the names of the classifier layers must match the classifier names in the GCBM input database
          - tags=[classifier_tag] ensures that classifier layers are automatically added to the GCBM
            configuration file
        '''
        classifier_tag = "classifier"
        reporting_classifier_tag = "reporting_classifier"
        
        classifier_layers = [
            VectorLayer("ForestType", os.path.join(layer_root, "inventory", "inventory.shp"), Attribute("ForestType"), tags=[classifier_tag]),
            VectorLayer("Disturbanc", os.path.join(layer_root, "inventory", "inventory.shp"), Attribute("Disturbanc"), tags=[classifier_tag]),
            VectorLayer("Climate", os.path.join(layer_root, "inventory", "inventory.shp"), Attribute("Climate"), tags=[classifier_tag]),
        ]
        
        # Set up default transition rule for disturbance events: preserve existing stand classifiers.
        no_classifier_transition = OrderedDict(zip((c.name for c in classifier_layers), "?" * len(classifier_layers)))

        layers = [
            # Age - layer name must be "initial_age" so that the script can update the GCBM configuration file.
            VectorLayer("initial_age", os.path.join(layer_root, "inventory", "inventory.shp"), Attribute("Age"),
                        data_type=gdal.GDT_Int16, raw=True),
            
            # Temperature - layer name must be "mean_annual_temperature" so that the scripts can
            # update the GCBM configuration file.
            VectorLayer("mean_annual_temperature",
                        os.path.join(layer_root, "inventory", "inventory.shp"), Attribute("AnnualTemp"),
                        data_type=gdal.GDT_Float32, raw=True),
        ] + classifier_layers
        
        '''
        # Disturbances
        for year in range(2010, 2020):
            layers.append(DisturbanceLayer(
                rule_manager,
                VectorLayer("disturbances_{}".format(year),
                            os.path.join(layer_root, "disturbances", "disturbances.shp"),
                            [
                                Attribute("year", filter=ValueFilter(year)),
                                Attribute("dist_type")
                            ]),
                year=Attribute("year"),
                disturbance_type=Attribute("dist_type"),
                transition=TransitionRule(
                    regen_delay=0,
                    age_after=0,
                    classifiers=no_classifier_transition)))
        '''
        
        tiler.tile(layers)
        rule_manager.write_rules("transition_rules.csv")
