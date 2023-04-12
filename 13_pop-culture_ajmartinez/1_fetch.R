source("1_fetch/src/get_data.R")

# Fetch input data via download and manual download
p1_targets <- list(

  # Download fire perimeter data from MTBS
  tar_target(
    perim,
    get_fire_perim(
      url = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/fod_pt_shapefile/mtbs_fod_pts_data.zip",
      perim_zip_path = "1_fetch/tmp/mtbs.zip",
      perim_tmp_path = "1_fetch/tmp",
      crs = crs
    )
  ),

  # Load Forests 2 Faucets 2.0 data
  # Can't figure out how to download directly from Box
  # Data available from
  #   https://usfs-public.app.box.com/v/Forests2Faucets/file/938183618458
  # To read a geodatabase, file_in = [path and name of geodatabase.gdb]
  #   and layer = [name of layer]
  # To read a shapefile, file_in = [path and name shapefile]
  tar_target(
    f2f2_huc12,
    get_huc(
      file_in = "1_fetch/in/F2F2_2019.gdb", layer = "F2F2_HUC12",
      crs = crs
    )
  ),

  # Download basemap tiles
  tar_target(
    basemap,
    get_basemap(
      file_in_for_extent = f2f2_huc12,
      file_out = "1_fetch/out/basemap.tif"
    ),
    format = "file"
  ),
  
  tar_target(
    usgs_logo_file,
    "1_fetch/in/usgs_logo_white.png",
    format = "file"
  )
)
