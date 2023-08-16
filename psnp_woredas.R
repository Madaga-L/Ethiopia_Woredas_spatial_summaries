# Load required packages
library(data.table)
library(sf) 

setwd("H:/CIMMYT Shiny project/Ethiopia")

# Read the PSNP_woredas.csv file
psnp_woredas <- read.csv("PSNP_woredas.csv")

# Read the Woreda shapefile
woreda_shapefile <- st_read("eth_admbnda_adm3_csa_bofedb_2021.shp")

# Create a new column in the PSNP_woredas data frame
psnp_woredas$ADM3_PCODE <- NA

# Iterate through PSNP woredas and find matching ADM3_PCODE
for (i in 1:nrow(psnp_woredas)) {
  psnp_woreda <- psnp_woredas[i, ]
  woreda <- woreda_shapefile[woreda_shapefile$ADM3_EN == psnp_woreda$Wereda, ]
  
  if (nrow(woreda) > 0) {
    psnp_woredas[i, "ADM3_PCODE"] <- woreda$ADM3_PCODE
  }
}

# Save the modified PSNP_woredas.csv file
write.csv(psnp_woredas, "PSNP_woredas_modified2.csv")
