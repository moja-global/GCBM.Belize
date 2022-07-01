from statistics import mean
import pandas as pd
import os
import json

dom_sensitivity_full = pd.read_csv(os.path.join("Tables","Pools_DOM_Sensitivity_full.csv"))

def calc_metrics(ind_type):
    indicator = dom_sensitivity_full[dom_sensitivity_full['indicator'] == ind_type]
    dry = indicator[indicator['LifeZone'] == 'Tropical Dry']
    moist = indicator[indicator['LifeZone'] == 'Tropical Moist']
    wet = indicator[indicator['LifeZone'] == 'Tropical Premontane Wet']

    metrics = [
        {
            'type' : "Deadwood, Tropical Dry",
            'pool_tc_sum_MEAN' : format(dry['pool_tc_sum'].mean(),'.2f'),
            'area_sum_MEAN' : format(dry['area_sum'].mean(),'.2f'),
            'pool_tc_per_ha_MEAN': format(dry['pool_tc_per_ha'].mean(),'.2f'),
        },
        {
            'type' : "Deadwood, Tropical Moist",
            'pool_tc_sum_MEAN' : format(moist['pool_tc_sum'].mean(),'.2f'),
            'area_sum_MEAN' : format(moist['area_sum'].mean(),'.2f'),
            'pool_tc_per_ha_MEAN': format(moist['pool_tc_per_ha'].mean(),'.2f'),
        },
        {
            'type' : "Deadwood, Tropical Premontane Wet",
            'pool_tc_sum_MEAN' : format(wet['pool_tc_sum'].mean(),'.2f'),
            'area_sum_MEAN' : format(wet['area_sum'].mean(),'.2f'),
            'pool_tc_per_ha_MEAN': format(wet['pool_tc_per_ha'].mean(),'.2f')
        }
    ]
    formated_ind_type = ind_type.replace(' ','_')
    with open(os.path.join('metrics',f'{formated_ind_type}.json'),'w') as out:
        json.dump(metrics,out)

if __name__ == "__main__":
    indicators = dom_sensitivity_full['indicator'].unique()
    for ind_type in indicators:
        calc_metrics(ind_type)
