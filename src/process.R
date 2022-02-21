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

# Reload fitbit data with new column specs
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
weightLogInfo <- weightLogInfo %>% select(-Fat)


# Merge data sets by daily, hourly, and minute record

## DAILY RECORDS: `dailyActivity` and `sleepDay`
# Change `sleepDay` date-time column to date
sleepDay$SleepDay <- as.Date(sleepDay$SleepDay)
# Left join `sleepDay` on `dailyActivity`
data_day <- left_join(dailyActivity, sleepDay, by=c('Id', 'ActivityDate' = 'SleepDay'))
table(complete.cases(data_day)) # only 413/943 observations are complete cases
# Extract min, avg, and max heart rate for the day from `heartrate_seconds` table
dailyHeartrate <- heartrate_seconds %>% 
  mutate('Date' = floor_date(Time, 'day')) %>% 
  group_by(Id, Date) %>% 
  summarise('minHeartRate' = min(Value), 'avgHeartRate' = mean(Value), 'maxHeartRate' = max(Value))
# Left join `dailyHeartrate` on data_day
data_day <- left_join(data_day, dailyHeartrate, by=c('Id', 'ActivityDate' = 'Date'))
table(complete.cases(data_day)) # only 182/943 observations are complete cases
# Extract min, avg, and max METs for the day from `minuteMETsNarrow` table
dailyMETs <- minuteMETsNarrow %>%
  mutate('Date' = floor_date(ActivityMinute, 'day')) %>%
  group_by(Id, Date) %>%
  summarise('minMET' = min(METs), 'avgMET' = mean(METs), 'maxMET' = max(METs))
# Left join `dailyMETs` on data_day
data_day <- left_join(data_day, dailyMETs, by=c('Id', 'ActivityDate' = 'Date'))
table(complete.cases(data_day)) # only 182/943 observations are complete cases (same)
# Check if there are any duplicate weight records in one day
weightLogInfo %>% mutate(Date = as.Date(Date)) %>% group_by(Id, Date) %>% tally() %>% table()
# Only 8 participants recorded their weight at least once; none of the participants have a consistent record
# Nonetheless, these will be extracted and joined to `data_day`
weightLogInfo <- weightLogInfo %>% 
  mutate(Date = as.Date(Date)) %>%
  select(-LogId)
data_day <- left_join(data_day, weightLogInfo, by=c('Id', 'ActivityDate' = 'Date'))
# Add day column
data_day <- data_day %>%
  mutate('ActivityDay' = wday(ActivityDate, label=TRUE))
table(complete.cases(data_day)) # only 32/943 observations are complete cases (same)

## HOURLY RECORDS: `hourlyCalories`, `hourlyIntensities`, `hourlySteps`
# Extract hourly heart rate, sleep, and METs data
hourlyHeartrate <- heartrate_seconds %>% 
  mutate('Time' = floor_date(Time, 'hour')) %>%
  group_by(Id, Time) %>%
  summarise('minHeartRate' = min(Value), 'avgHeartRate' = mean(Value), 'maxHeartRate' = max(Value))
hourlySleep <- minuteSleep %>%
  mutate('Time' = floor_date(date, 'hour')) %>% 
  group_by(Id, Time) %>%
  count(value) %>%
  pivot_wider(names_from = value, names_prefix = 'sleep', values_from = n, values_fill = 0)
hourlyMETs <- minuteMETsNarrow %>%
  mutate('Time' = floor_date(ActivityMinute, 'hour')) %>%
  group_by(Id, Time) %>%
  summarise('minMET' = min(METs), 'avgMET' = mean(METs), 'maxMET' = max(METs))
# Perform series of left joins to merge data tables
data_hour <- left_join(hourlySteps, hourlyIntensities, by=c('Id', 'ActivityHour')) %>%
  left_join(., hourlyCalories, by=c('Id', 'ActivityHour')) %>%
  left_join(., hourlySleep, by=c('Id', 'ActivityHour'='Time')) %>%
  left_join(., hourlyHeartrate, by=c('Id', 'ActivityHour' = 'Time')) %>%
  left_join(., hourlyMETs, by=c('Id', 'ActivityHour' = 'Time'))

## MINUTELY RECORDS: `minuteCaloriesNarrow`, `minuteIntensitiesNarrow`, `minuteMETsNarrow`, `minuteSleep`, `minuteStepsNarrow`
# Extract minutely heart rate
minuteHeartrate <- heartrate_seconds %>% 
  mutate('Time' = floor_date(Time, 'minute')) %>%
  group_by(Id, Time) %>%
  summarise('minHeartRate' = min(Value), 'avgHeartRate' = mean(Value), 'maxHeartRate' = max(Value))
# Change format of date column in `minuteSleep` table
minuteSleep <- mutate(minuteSleep, date = floor_date(date, 'minute'))
# Perform series of left joins to merge data tables
data_minute <- left_join(minuteStepsNarrow, minuteIntensitiesNarrow, by=c('Id', 'ActivityMinute')) %>%
  left_join(., minuteCaloriesNarrow, by=c('Id', 'ActivityMinute')) %>% 
  left_join(., minuteSleep, by=c('Id', 'ActivityMinute'='date')) %>%
  left_join(., minuteHeartrate, by=c('Id', 'ActivityMinute'='Time')) %>%
  left_join(., minuteMETsNarrow, by=c('Id', 'ActivityMinute'))
