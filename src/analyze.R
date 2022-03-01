# Q1. What is the usage pattern across the month?
# Visualize users into groups of usage patterns
data_month %>% 
  mutate(Calories_bin = factor(ntile(Calories_sum, n=3))) %>%
  ggplot() +
  geom_point(mapping=aes(x=reorder(Id, Calories_sum), y=Calories_sum, color=Calories_bin), size=3) +
  theme(axis.text.x = element_blank(), axis.title.x = element_blank())

# Visualize users by number of records
data_day %>%
  group_by(Id) %>%
  count() %>%
  mutate(UsagePattern = factor(cut(n, breaks=c(0, 10,20,30,31), 
                                   labels = c('Rarely', 'Occasionally', 'Frequently', 'Daily')))) %>%
  ggplot() +
  geom_bar(mapping = aes(x=n, fill=UsagePattern)) +
  xlab('# of days recorded') +
  ylab('User count')

# Bin users by number of records
data_month <- data_day %>%
  group_by(Id) %>%
  count() %>%
  mutate(UsagePattern = factor(cut(n, breaks=c(0, 10,20,30,31), 
                                   labels = c('Rarely', 'Occasionally', 'Frequently', 'Daily')))) %>%
  right_join(.,data_month, by=c('Id'))

# Visualize "Calories_sum" again by user bin
data_month %>% 
  ggplot() +
  geom_point(mapping=aes(x=reorder(Id, Calories_sum), y=Calories_sum, color=UsagePattern), size=3) +
  theme(axis.text.x = element_blank(), axis.title.x = element_blank())
# Visualize "Calories_mean" by user bin
data_month %>% 
  ggplot() +
  geom_point(mapping=aes(x=reorder(Id, Calories_mean), y=Calories_mean, color=UsagePattern), size=3) +
  theme(axis.text.x = element_blank(), axis.title.x = element_blank())
data_month %>% 
  ggplot() +
  geom_point(mapping=aes(x=reorder(Id, TotalSteps_mean), y=TotalSteps_mean, color=UsagePattern), size=3) +
  theme(axis.text.x = element_blank(), axis.title.x = element_blank())

# Q2. What is the usage trend across the month
# How many records are there for each day of the week?
table(data_day$ActivityDay)
# Expected value of records for each day of the week
nrow(data_day)/7 # #> [1] 134.7142

# Graph visualization
ggplot(data=data_day) +
  geom_bar(mapping=aes(x=ActivityDay))
## Shows slightly higher number of records for Tue, Wed, Thu

# Chi-squared test for goodness of fit
chisq.test(table(data_day$ActivityDay))
## shows that differences record counts for each day are not statistically significant (p-value = 0.1467)

# Were users more active on specific days of the week?
ggplot(data=data_day, aes(x=ActivityDay, y=TotalSteps)) +
  geom_violin(aes(fill=ActivityDay)) +
  # geom_boxplot() +
  geom_jitter()


# Graph of daily calories burned across all users shows a drop after around a month of activity
ggplot(data=data_day) +
  geom_smooth(mapping=aes(x=ActivityDate, y=Calories)) +
  theme(legend.position = "none")
# There are several possible explanations for this
## 1. Normal users can only stay motivated to exercise for ~1 month
## 2. Users were active, but did not burn as much calories
## 3. Something happened in May 2016 that prevented users from doing activities (may need more data to predict trends)

# Same trend is visible with other variables
ggplot(data=data_day) + 
  geom_smooth(mapping=aes(x=ActivityDate, y=TotalSteps)) +
  # geom_smooth(mapping=aes(x=ActivityDate, y=TotalDistance)) +
  # geom_smooth(mapping=aes(x=ActivityDate, y=TrackerDistance)) +
  theme(legend.position = "none")

# Time in bed and time spent sleeping 
ggplot(data=data_day) + 
  geom_vline(xintercept = data_day$ActivityDate[which(data_day$ActivityDay == 'Sat' | data_day$ActivityDay == 'Sun')]) +
  geom_smooth(mapping = aes(x=ActivityDate, y=TotalMinutesAsleep), color='blue') +
  geom_smooth(mapping = aes(x=ActivityDate, y=TotalTimeInBed), color='red') +
  theme_minimal()

