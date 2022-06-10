# ----------------------------
# Make Tables and Figures for the GCBM estimations on DOM pools
# ----------------------------

#------------------------------------------------------
# Library management

# Necesary libraries
library(ggplot2) # produce figures
library(readr) # Read data
library(tidyr) # Data cleaning
library(dplyr) # Data processing
library(RSQLite) # Connect with the SQLite database
library(writexl) # Write tables in excel format

# Avoid scientific notation
options(scipen=10000)

#------------------------

# List the directories of the different GCBM runs
# Here only one directory is listed, but mode than one can be made to make a sensitivity analysis
# e.g. runs <- c('../Standalone_GCBM','../Standalone_GCBM_decaymod','../Standalone_GCBM_turnovermod')
runs <- c('../Standalone_GCBM')


# Make a named vector to point the name you want each run to have in the graph
# Here only one name is listed, but mode than one can be made to make a sensitivity analysis
# e.g. names_runs <- c('Default','Modified Decay parameters',Modified Decay, Turnover and Spinup parameters')
names_runs <- c('Modified Decay, Turnover and Spinup parameters')
names_runs <- c('../Standalone_GCBM' = 'Modified Decay, Turnover and Spinup parameters')

#Loop though the runs
for (run in runs) {
  
  # Path to the database
  path_db<-paste0(run,"/processed_output/compiled_gcbm_output.db")
  #----------------------
  
  # Connect to the database
  conn <- dbConnect(RSQLite::SQLite(), path_db)
  
  # List the tables in the databases
  dbListTables(conn)
  
  # Pool indicators
  pool_ind<-dbGetQuery(conn, "SELECT * FROM v_pool_indicators")

  
  # Calculate the pools total carbon for forests per lifezone and year
  pools_run<-pool_ind %>% filter(indicator %in% c("Total Biomass","Deadwood","Litter","Soil Carbon")) %>% 
    group_by(year,indicator,LifeZone) %>% 
    summarize(pool_tc_sum=sum(pool_tc))
  
  
  # Get the areas for each lifezone
  age_ind<-dbGetQuery(conn, "SELECT * FROM v_age_indicators")
  areas_run<-age_ind %>%  
    group_by(year,LifeZone) %>% 
    summarize(area_sum=sum(area)) %>% 
    ungroup()
  
  # Divide the DOM values per area to obtain ton/ha values
  pools_run_area <- left_join(pools_run,areas_run,by = c("year","LifeZone"))
  pools_run_area <- mutate(pools_run_area, pool_tc_per_ha = pool_tc_sum/area_sum)
  pools_run_area$run <- run
  
  # Make a compiled database
  if(exists("pools_full")){
    pools_full <- rbind(pools_full,pools_run_area)
  } else {
    pools_full <- pools_run_area
  }
  
  print(run)
  
  dbDisconnect(conn)

}

unique(pools_full$run)

# Change the name of the lifezone for simpler figures
pools_full$LifeZone <- as.character(recode(pools_full$LifeZone,
                                          "Tropical Premontane Wet, Transition to Basal - Atlantic" = "Tropical Premontane Wet"))



# Recode the runs to put prettier names in the figures
pools_full$run <- as.character(recode(pools_full$run, !!!names_runs))

# Check the recoding
unique(pools_full$run)

#Write full table
write_csv(pools_full,"./Tables/Pools_DOM_Sensitivity_full.csv")


# Make a Table with the DOM stocks every 10 years, from 0 to 150 years old
pools_summary <- pools_full %>% 
  filter(year %in% seq(1900,2050,by=10)) %>% 
  mutate(Age = year - 1900)

for (ag in unique(pools_summary$Age)) {
  
  # Make a pools table for that specific age (ag)
  pools_forest <- pools_summary %>% 
    filter(Age == ag) %>% 
    select(indicator,LifeZone,pool_tc_per_ha,run) %>% 
    pivot_wider(names_from = run,values_from = pool_tc_per_ha)
  
  # Write a table every 10 years
  write_csv(pools_forest,paste0("./Tables/Pools_DOM_Sensitivity_forest_",ag,"_years.csv"))

}

# Make figures for each life zone in Belize

# Tropical dry
p <- ggplot(filter(pools_full,LifeZone=="Tropical Dry"),aes(x=year,y=pool_tc_per_ha,fill=indicator))+
  geom_area() +
  facet_grid(indicator~run,labeller = label_wrap_gen(width=7)) +
  ylab("Carbon Stock (ton C / ha)") +
  scale_fill_manual(values=c("darkgoldenrod4","chartreuse3","gray14","forestgreen")) +
  ggtitle("Carbon Stocks of Tropical Dry Forests (Belize) - GCBM Sensitivity analysis") +
  theme_bw(14) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

p

ggsave(file=paste0("Figures/Belize_Sensitivity_TropicalDry.png"), width=300,height=180,units="mm",dpi=300)

# Tropical Moist
p <- ggplot(filter(pools_full,LifeZone=="Tropical Moist"),aes(x=year,y=pool_tc_per_ha,fill=indicator))+
  geom_area() +
  facet_grid(indicator~run,labeller = label_wrap_gen(width=7)) +
  ylab("Carbon Stock (ton C / ha)") +
  scale_fill_manual(values=c("darkgoldenrod4","chartreuse3","gray14","forestgreen")) +
  ggtitle("Carbon Stocks of Tropical Moist Forests (Belize) - GCBM Sensitivity analysis") +
  theme_bw(14) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

p

ggsave(file=paste0("Figures/Belize_Sensitivity_TropicalMoist.png"), width=300,height=180,units="mm",dpi=300)

# Tropical Premontane wet
p <- ggplot(filter(pools_full,LifeZone=="Tropical Premontane Wet"),aes(x=year,y=pool_tc_per_ha,fill=indicator))+
  geom_area() +
  facet_grid(indicator~run,labeller = label_wrap_gen(width=7)) +
  ylab("Carbon Stock (ton C / ha)") +
  scale_fill_manual(values=c("darkgoldenrod4","chartreuse3","gray14","forestgreen")) +
  ggtitle("Carbon Stocks of Tropical Premontane Wet Forests (Belize) - GCBM Sensitivity analysis") +
  theme_bw(14) +
theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

p

ggsave(file=paste0("Figures/Belize_Sensitivity_TropicalPremontane.png"), width=300,height=180,units="mm",dpi=300)
                  


