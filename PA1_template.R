unzip('activity.zip')
activityData <- read.csv('activity.csv')
head(activityData)

stepsPerDay <- tapply(activityData$steps, 
                      activityData$date, 
                      sum, na.rm=T)
stepsPerDay
library(ggplot2)
dailySteps <- ggplot(as.data.frame(stepsPerDay), 
                     aes(x=stepsPerDay)) + 
  geom_histogram() + 
  xlab('total steps per day')
dailySteps
mean(stepsPerDay)
median(stepsPerDay)

averageIntervalSteps <- tapply(activityData$steps, 
                               activityData$interval, 
                               mean, na.rm=T)
averageIntervalSteps
intervalSteps <- ggplot(as.data.frame(averageIntervalSteps), 
                        aes(x=as.numeric(names(averageIntervalSteps)),
                            y=averageIntervalSteps)) + 
  geom_line() +
  xlab('five-minute interval') +
  ylab('average number of steps')
intervalSteps
names(averageIntervalSteps)[which(averageIntervalSteps == max(averageIntervalSteps))]

sum(is.na(activityData$steps))
imputedSteps <- sapply(1:nrow(activityData), function(x){
  if(is.na(activityData[x,'steps'])){
    interval <- as.character(activityData[x,'interval'])
    return(averageIntervalSteps[interval])
  } else {
    return(activityData[x,'steps'])
  }
})
sum(is.na(imputedSteps))
imputedData <- data.frame(imputedSteps = imputedSteps,
                          date = activityData$date,
                          interval = activityData$interval)
head(imputedData)

imputedStepsPerDay <- tapply(imputedData$imputedSteps, 
                      imputedData$date, 
                      sum, na.rm=T)
imputedDailySteps <- ggplot(as.data.frame(imputedStepsPerDay), 
                            aes(x=imputedStepsPerDay)) + 
  geom_histogram() + 
  xlab('total steps per day')
imputedDailySteps
mean(imputedStepsPerDay)
median(imputedStepsPerDay)

weekday <- sapply(imputedData$date, function(x){
  if(weekdays(as.Date(x)) == 'Sunday' | weekdays(as.Date(x)) == 'Saturday'){
    return('weekend')
  } else {
    return('weekday')
  }
})
imputedData <- data.frame(imputedData,
                          weekday = weekday)
weekdayVsEnd <- ggplot(data=imputedData,
                       aes(x=interval, 
                           y=imputedSteps)) +
  geom_line(stat="summary", fun.y="mean") +
  facet_grid(weekday ~ .) +
  xlab('five-minute interval') +
  ylab('average number of steps (imputed data)')
weekdayVsEnd
