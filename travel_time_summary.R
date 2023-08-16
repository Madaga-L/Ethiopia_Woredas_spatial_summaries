#spatial summaries
#this script is used to extract spatial summaries of 
#Average travel time to towns - https://figshare.com/articles/dataset/Travel_time_to_cities_and_ports_in_the_year_2015/7638134
#Average rural population density - https://hub.worldpop.org/project/categories?id=18
#Average BioClim variables - https://www.worldclim.org/data/bioclim.html
#for Ethiopian Woredas

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


# Provide the paths to your rasters
towns_fiftyk <- "H:/CIMMYT Shiny project/Ethiopia/Spatial summaries/EThiopia_towns_fiftyk.tif"

# Read the raster files
r_travel_time <- rast(towns_fiftyk)

# create raster version of woredas to match grids which will be summarized
wgrid <- rasterize(vect(woreda_shapefile), r_travel_time, field="Unique_ID")

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
zout <- myZonal(r_travel_time,wgrid)
zout


# Remove rows with NaN values
zout_clean <- zout[complete.cases(zout), ]
zout_clean

matchlist <- match(woreda_shapefile$Unique_ID, zout_clean$Unique_ID)
zout_clean <- zout_clean[matchlist,] # just keeps the rows that match codes in the shapefile (i.e. drops the NAs)
zout_clean

zout_clean <- zout_clean[data.table(woreda_shapefile), on = .(Unique_ID = Unique_ID)]
zout_clean

# and tidy up the rest
#specify fields to keep
fields_to_keep <- c("Unique_ID","EThiopia_towns_fiftyk", "Shape_Leng", "Shape_Area", 
                    "ADM3_EN",  "ADM3_PCODE", "ADM3ALT1EN", 
                    "ADM2_EN", "ADM2_PCODE", "ADM1_EN", "ADM1_PCODE", 
                    "ADM0_EN", "ADM0_PCODE", "date", "validOn", "validTo")

zout_clean <- zout_clean[, ..fields_to_keep]

# export to csv
write.csv(zout_clean, file = "travel_time.csv", na = ".")
