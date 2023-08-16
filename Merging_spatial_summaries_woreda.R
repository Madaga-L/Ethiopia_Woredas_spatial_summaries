#spatial summaries
#this script is used to extract spatial summaries of 
#Average travel time to towns - https://figshare.com/articles/dataset/Travel_time_to_cities_and_ports_in_the_year_2015/7638134
#Average rural population density - https://hub.worldpop.org/project/categories?id=18
#Average BioClim variables - https://www.worldclim.org/data/bioclim.html
#for Ethiopian Woredas

# Set working directory
setwd("H:/CIMMYT Shiny project/Ethiopia/Spatial summaries")

# Load required packages

library(data.table)

#now join the CSV files based on a common field 

#Read your CSV files
travel_time <- read.csv("travel_time.csv")
pop_density <- read.csv("population.csv")
bioclim_data <- read.csv("bioclim.csv")

#Merge the data frames using the merge() function
merged_data <- merge(travel_time, pop_density, by = "Unique_ID", all.x = TRUE)
merged_data <- merge(merged_data, bioclim_data, by = "Unique_ID", all.x = TRUE)
