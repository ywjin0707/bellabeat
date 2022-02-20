# Q1. What

# Q1. What is the usage trend across the month
# Graph of daily calories burned across all users shows a drop after around a month of activity
ggplot(data=data_day) +
  geom_smooth(mapping=aes(x=ActivityDate, y=Calories), color='red') +
  theme(legend.position = "none")
# There are several possible explanations for this
## 1. Normal users can only stay motivated to exercise for ~1 month
## 2. Users were active, but did not burn as much calories
## 3. Something happened in May 2016 that prevented users from doing activities (may need more data to predict trends)

# Same trend is visible with other variables
ggplot(data=data_day) + 
  geom_smooth(mapping=aes(x=ActivityDate, y=TotalSteps), color='green') +
  # geom_smooth(mapping=aes(x=ActivityDate, y=TotalDistance), color='black') +
  # geom_smooth(mapping=aes(x=ActivityDate, y=TrackerDistance), color='grey') +
  theme(legend.position = "none")

# Which days of the week were users most active?
ggplot(data=data_day) +
  geom_violin(mapping=aes(x=wday(ActivityDate, label=TRUE), y=Calories))
