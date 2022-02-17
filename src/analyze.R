# Graph of daily calories burned across all users shows a drop after around a month of activity
ggplot(data=dailyActivity) +
  geom_smooth(mapping=aes(x=ActivityDate, y=Calories)) +
  theme(legend.position = "none")
# There are several possible explanations for this
## 1. Normal users can only stay motivated to exercise for ~1 month
## 2. Users were active, but did not burn as much calories
## 3. Something happened in May 2016 that prevented users from doing activities (may need more data to predict trends)


