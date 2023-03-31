library(here)
setwd(here("00_template_elmera_azadpour"))
library(targets)

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c('tidyverse', 'sbtools',
                            "readr",
                            "janitor",
                            "rlang",
                            'showtext', 'scico'))

source("src/data_utils.R")

list(

  # Load necessary files  ---------------------------------------------------
  # Download water quality data from ScienceBase
  tar_target(
    decadal_gw_csv,
    item_file_download(
      sb_id = "628e0f4ed34ef70cdba3f98d",
      names = "Water_Quality_Data_V6.csv",
      destinations = "out/Water_Quality_Data_V6.csv"
    ),
    format = "file"),

  # Download decadal change network wells from ScienceBase
  tar_target(
    wells_csv,
    item_file_download(
      sb_id = "628e0f4ed34ef70cdba3f98d",
      names = "Decadal_Change_Network_Wells_V6.csv",
      destinations = "out/Decadal_Change_Network_Wells_V6.csv"
    ),
    format = "file"),

  # Download decadal change network centroid from ScienceBase
  tar_target(
    wells_centroid_csv,
    item_file_download(
      sb_id = "628e0f4ed34ef70cdba3f98d",
      names = "Decadal_Change_Network_Centroids_V6.csv",
      destinations = "out/Decadal_Change_Network_Centroids_V6.csv"
    ),
    format = "file"),

  # Download decadal data dictionary
  tar_target(
    data_dictionary_csv,
    item_file_download(
      sb_id = "628e0f4ed34ef70cdba3f98d",
      names = "Decadal_Data_Dictionary_V6.csv",
      destinations = "out/Decadal_Data_Dictionary_V6.csv"
    ),
    format = "file"),

  # Water quality thresholds data - adapted from Belitz et al., 2022, Table S4
  tar_target(
    wq_thresholds_csv,
    "https://labs.waterdata.usgs.gov/visualizations/23_chart_challenge/Water_Quality_Thresholds.csv"
  ),

  # Water quality thresholds metadata - adapted from Belitz et al., 2022, Table S4 Notes
  tar_target(
    wq_thresholds_meta_csv,
    "https://labs.waterdata.usgs.gov/visualizations/23_chart_challenge/Metadata_Water_Quality_Thresholds.csv"
  ),

  # Water quality thresholds pH/DO
  tar_target(
    wq_thresholds_pH_DO_csv,
    "https://labs.waterdata.usgs.gov/visualizations/23_chart_challenge/Water_Quality_Thresholds_pH_DO.csv"
  ),

  # NAWQA Study unit names and abbreviations crosswalk
  tar_target(
    nawqa_study_unit_xwalk_csv,
    "https://labs.waterdata.usgs.gov/visualizations/23_chart_challenge/NAWQA_map_study_unit.csv"
  ),

  tar_target(
    munge_decadal_gw,
    tidy_decadal_gw_wq(
      wq_data = decadal_gw_csv,
      sampling_event_subset = "CY3"
    )
  ),
  tar_target(
    filter_decadal_gw,
    filter_wells_wq(
      wq_tidy_data = munge_decadal_gw,
      wells_data = wells_csv,
      data_dic = data_dictionary_csv,
      filter_parm = c("do", "ph", "as", "co", "f", "fe", "li", "mn", "mo", "sr", "u", "pb", "ra226", "ra228", "ra_226_228", "no3")
    )
  ),
  tar_target(
    threshold_decadal_gw,
    thresholds_wq(
      thresholds_data = wq_thresholds_csv,
      ph_do_thresholds_data = wq_thresholds_pH_DO_csv,
      filtered_data = filter_decadal_gw,
      constituents_of_interest = c("Arsenic", "Cobalt", "Fluoride", "Iron", "Lithium-DW",
                                   "Lithium-HHB","Manganese", "Molybdenum","Strontium",
                                   "Uranium", "Lead-210", "sum Ra (Radium-226+Radium-228)", "Nitrate (as nitrogen)"),
      constituent_abv = c("as", "co", "f", "fe", "li", "li", "mn", "mo", "sr", "u", "pb", "ra_226_228",
                          "no3"),
      nawqa_xwalk = nawqa_study_unit_xwalk_csv,
      organic_thresh = 0.1, # Belitz et al., 2022, Table S4
      inorganic_thresh = 0.5, # Belitz et al., 2022, Table S4
      do_low_thresh = 0.5, # McMahon & Chapelle, 2008
      do_high_thresh = 2.0, # McMahon et al., 2008 & Tesoriero et al., 2015
      ph_low_thresh = 6.5, # EPA National Secondary Drinking Water Regulations (NSDWRs)
      ph_high_thresh = 8.5 # EPA National Secondary Drinking Water Regulations (NSDWRs)
    )
  )
)
