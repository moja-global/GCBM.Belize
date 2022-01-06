CREATE INDEX IF NOT EXISTS disturbancedimension_location_idx{table_suffix} ON disturbancedimension{table_suffix} (locationdimid);
CREATE INDEX IF NOT EXISTS disturbancedimension_disturbancetype_idx{table_suffix} ON disturbancedimension{table_suffix} (disturbancetypedimid);
CREATE INDEX IF NOT EXISTS fluxes_location_idx{table_suffix} ON fluxes{table_suffix} (locationdimid);
CREATE INDEX IF NOT EXISTS fluxes_pools_idx{table_suffix} ON fluxes{table_suffix} (poolsrcdimid, pooldstdimid);
CREATE INDEX IF NOT EXISTS disturbance_fluxes_idx{table_suffix} ON fluxes{table_suffix} (disturbancedimid) WHERE disturbancedimid IS NULL;
CREATE INDEX IF NOT EXISTS annual_process_fluxes_idx{table_suffix} ON fluxes{table_suffix} (disturbancedimid) WHERE disturbancedimid IS NOT NULL;
CREATE INDEX IF NOT EXISTS pools_location_idx{table_suffix} ON pools{table_suffix} (locationdimid);
CREATE INDEX IF NOT EXISTS locationerrordimension_location_idx{table_suffix} ON locationerrordimension{table_suffix} (locationdimid);
CREATE INDEX IF NOT EXISTS agearea_location_idx{table_suffix} ON agearea{table_suffix} (locationdimid);
