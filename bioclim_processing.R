library(terra)

# Read the Woreda shapefile
woreda_shapefile <- st_read("H:/CIMMYT Shiny project/Ethiopia/Spatial summaries/eth_admbnda_adm3_csa_bofedb_2021.shp")


# Provide the path to your BioClim stacked raster
bioclim_stacked <- rast("stacked_bioclim.tif")

# Project the bioclim stacked raster to the CRS of the woreda_shapefile
bioclim_stacked_projected <- project(bioclim_stacked, crs = st_crs(woreda_shapefile))


# Mask the BioClim raster to Ethiopia's boundary
bioclim_ethiopia <- terra::mask(bioclim_stacked, woreda_shapefile)

# Continue with your analysis, e.g., summarizing travel time and population density

# Save the masked BioClim raster
writeRaster(bioclim_ethiopia, filename = "bioclim_ethiopia.tif", format = "GTiff")
