# Set working directory
setwd("H:/CIMMYT Shiny project/Ethiopia/Spatial summaries")

# Load required packages
library(sf)    
library(terra)
library(dplyr)
library(data.table)

# Read the Woreda shapefile
woreda_shapefile <- sf::read_sf("eth_admbnda_adm3_csa_bofedb_2021.shp")

woreda_shapefile$Unique_ID <- seq_len(nrow(woreda_shapefile))
woreda_shapefile$Unique_ID <- match(woreda_shapefile$ADM3_PCODE, unique(woreda_shapefile$ADM3_PCODE))


avg_bioclim_raster <- "H:/CIMMYT Shiny project/Ethiopia/Spatial summaries/masked_bioclim_data_prj.tif"


# Read the bioclim raster file
#Already stacked bioclim dataset
r_avg_bioclim <- rast(avg_bioclim_raster)

# create raster version of woredas to match grids which will be summarized
bgrid <- rasterize(vect(woreda_shapefile), r_avg_bioclim, field="Unique_ID")

#define function for zonal summary using data.table
myZonal <- function (x, Unique_ID, digits = 0, na.rm = FALSE, 
                     ...) {
  fun <- function(x) mean(x, na.rm=TRUE)
  vals <- values(x)
  zones <- round(values(Unique_ID), digits = digits)
  rDT <- data.table(vals, zones)
  setkey(rDT, Unique_ID)
  rDT[, lapply(.SD, fun), by=Unique_ID]
}

# now run the function, i.e., perform the zonal sum
zout <- myZonal(r_avg_bioclim,bgrid)
zout


# Remove rows with NaN values
zout_clean <- zout[complete.cases(zout), ]
zout_clean

matchlist <- match(woreda_shapefile$Unique_ID, zout_clean$Unique_ID)
zout_clean <- zout_clean[matchlist,] # just keeps the rows that match codes in the shapefile (i.e. drops the NAs)
zout_clean

zout_clean <- zout_clean[data.table(woreda_shapefile), on = .(Unique_ID = Unique_ID)]
zout_clean

# export to csv
write.csv(zout_clean, file = "bioclim.csv", na = ".")
