import os
import pandas as pd
import json

pools = pd.read_csv(os.path.join('Tables','Pools_DOM_Sensitivity_full.csv'))
pools_divided = [
    {'period':'1900-1950','data':pools[pools['year']<=1950]},
    {'period':'1951-2000','data':pools[(pools['year']>1950) & (pools['year']<=2000)]},
    {'period':'2001-2050','data':pools[pools['year']>2000]}
    ]

def calc_metrics(pool,ind_type):
    indicator = pool[pool['indicator'] == ind_type]
    dry = indicator[indicator['LifeZone'] == 'Tropical Dry']
    moist = indicator[indicator['LifeZone'] == 'Tropical Moist']
    wet = indicator[indicator['LifeZone'] == 'Tropical Premontane Wet']
    metrics = {
        'indicator':ind_type,
        "Tropical Dry":{
            'pool_tc_sum_MEAN' : format(dry['pool_tc_sum'].mean(),'.2f'),
            'area_sum_MEAN' : format(dry['area_sum'].mean(),'.2f'),
            'pool_tc_per_ha_MEAN': format(dry['pool_tc_per_ha'].mean(),'.2f')
        },
        "Tropical Moist":{
            'pool_tc_sum_MEAN' : format(moist['pool_tc_sum'].mean(),'.2f'),
            'area_sum_MEAN' : format(moist['area_sum'].mean(),'.2f'),
            'pool_tc_per_ha_MEAN': format(moist['pool_tc_per_ha'].mean(),'.2f'),
        },
        "Tropical Premontane Wet":{
            'pool_tc_sum_MEAN' : format(wet['pool_tc_sum'].mean(),'.2f'),
            'area_sum_MEAN' : format(wet['area_sum'].mean(),'.2f'),
            'pool_tc_per_ha_MEAN': format(wet['pool_tc_per_ha'].mean(),'.2f')
        }
    }
    return metrics

if __name__ == '__main__':
    indicators = pools['indicator'].unique()
    metrics = []
    for q in pools_divided:
        metrics.append(
            {'period':q['period'],'data':[]}
        )
    for ind_type in indicators:
        for i,q_metrics in enumerate(metrics):
            new_item = calc_metrics(pools_divided[i]['data'],ind_type)
            q_metrics['data'].append(new_item)
            with open(os.path.join('metrics',f"{q_metrics['period']}.json"),'w') as out:
                json.dump(q_metrics,out,indent=4)
                