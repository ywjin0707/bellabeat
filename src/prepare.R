# Load the required packages
library(tidyverse)
library(lubridate)

# Get list of filenames from data directory
data_directory <- './data/Fitabase Data 4.12.16-5.12.16/'
data_list <- list.files(data_directory)
data_list

data_names <- sapply(data_list, function(x){gsub('*_merged.csv', '', x)})

# Load fitbit data
for(i in 1:length(data_names)){
  assign(data_names[[i]], read_csv(paste0(data_directory, data_list[[i]])))
}

# Call each data set for inspection
dailyActivity

# The `dailyActivity` table is a superset of `dailyCalories`, `dailyIntensities`, and `dailySteps`
# Data sets can be classified into three categories; records by day, hour, and minute. 
# Only `heartrate_seconds` table has records every 5 seconds