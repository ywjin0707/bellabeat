# Some columns are formatted incorrectly
dailyActivity$Id <- as.factor(dailyActivity$Id)
dailyActivity$ActivityDate <- mdy(dailyActivity$ActivityDate)

# Check columns specs for each data table and change specs accordingly
spec(get(data_names[[1]]))

# List of column specs for each data set represented as compact string
# Error with parsing date-times this way - load as character and need to change formats
spec_list <- c('fcidddddddiiiii', #dailyActivity
               'fci', #dailyCalories
               'fciiiidddd', #dailyIntensities
               'fci', #dailySteps
               'fci', #heartrate_seconds
               'fci', #hourlyCalories
               'fcid', #hourlyIntensities
               'fci', #hourlySteps
               'fcd', #minuteCaloriesNarrow
               'fcdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd', #minuteCaloriesWide
               'fci', #minuteIntensitiesNarrow
               'fciiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii', #minuteIntensitiesWide
               'fci', #minuteMETsNarrow
               'fcif', #minuteSleep
               'fci', #minuteStepsNarrow
               'fciiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii', #minuteStepsWide
               'fciii', #sleepDay
               'fcddddlf') #weightLogInfoc

# Reload fitbit data
for(i in 1:length(data_names)){
  assign(data_names[[i]], read_csv(paste0(data_directory, data_list[[i]]), col_types=spec_list[[i]]))
}

# The first 4 data set have date, the rest have date-time in their 2nd column
dailyActivity$ActivityDate <- mdy(dailyActivity$ActivityDate)
dailyCalories$ActivityDay <- mdy(dailyCalories$ActivityDay)
dailyIntensities$ActivityDay <- mdy(dailyIntensities$ActivityDay)
dailySteps$ActivityDay <- mdy(dailySteps$ActivityDay)
heartrate_seconds$Time <- mdy_hms(heartrate_seconds$Time)
hourlyCalories$ActivityHour <- mdy_hms(hourlyCalories$ActivityHour)
hourlyIntensities$ActivityHour <- mdy_hms(hourlyIntensities$ActivityHour)
hourlySteps$ActivityHour <- mdy_hms(hourlySteps$ActivityHour)
minuteCaloriesNarrow$ActivityMinute <- mdy_hms(minuteCaloriesNarrow$ActivityMinute)
# minuteCaloriesWide # Will probably not use this data format
minuteIntensitiesNarrow$ActivityMinute <- mdy_hms(minuteIntensitiesNarrow$ActivityMinute)
# minuteIntensitiesWide # Will probably not use this data format
minuteMETsNarrow$ActivityMinute <- mdy_hms(minuteMETsNarrow$ActivityMinute)
minuteSleep$date <- mdy_hms(minuteSleep$date)
minuteStepsNarrow$ActivityMinute <- mdy_hms(minuteStepsNarrow$ActivityMinute)
# minuteStepsWide # Will probably not use this data format
sleepDay$SleepDay <- mdy_hms(sleepDay$SleepDay)
weightLogInfo$Date <- mdy_hms(weightLogInfo$Date)

# Check each data set for NA values
for(i in 1:length(data_names)){
  data_name = data_names[[i]]
  print(data_name)
  print(table(complete.cases(get(data_name))))
}
# All data set except for "weightLogInfo" table has no NA values
weightLogInfo
# There are many NA values for the column 'Fat'
table(is.na(weightLogInfo$Fat))
# There are only two values for the 'Fat' column so this should be removed

