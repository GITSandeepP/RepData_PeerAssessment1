# Load required libraries
library(dplyr)
library(lattice)

daytype <- function(day) {
        if  (!(day == 'Saturday' || day == 'Sunday')) {
                x <- 'Weekday'
        } else {
                x <- 'Weekend'
        }
        x
}

# Set Main directory path
maindir <- "/Users/mycomputer"
# Set Working directory path
path <- paste(maindir, "/Documents", sep = "")

# Check if desired working directory path exist or not
# if exist then set working directory else create directory and set it accordingly
if (dir.exists(file.path(path))){
        setwd(file.path(path))
}else {
        dir.create(file.path(maindir, "Documents"))
        setwd(file.path(path))
}

# Download the dataset to work on
fileurl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
download.file(fileurl, destfile = "repdataactivity.zip")

# As the dataset is in zip folder, unzip command is used to unzip the file
zipf <- paste(path, "/repdataactivity.zip", sep = "")
outdir <- paste(path, "/repdataactivity", sep = "")
unzip(zipf, exdir = outdir)

# 1
filepath <- paste(outdir, "/activity.csv", sep = "")

activity <- read.csv(filepath,
                     header = TRUE, sep = ",", stringsAsFactors = FALSE)

activity$date <- as.Date(as.character(activity$date))
no.na.activity <- activity[complete.cases(activity), ]

totalstepsperday <- no.na.activity %>% group_by(date) %>% summarize(totalsteps = sum(steps))

# 2
hist(totalstepsperday$totalsteps, xlab = "Total steps per day", main = "Histogram of total steps per day")

# with(totalstepsperday, plot(date, totalsteps, type = "l"))

# 3
mean.stepsperday <- mean(totalstepsperday$totalsteps)
print(paste("mean.stepsperday = ", mean.stepsperday))
median.stepsperday <- median(totalstepsperday$totalsteps)
print(paste("median.stepsperday = ", median.stepsperday))

# 4
averagesteps <- no.na.activity %>% group_by(interval) %>% summarize(avgsteps = mean(steps))

with(averagesteps, plot(interval,
                        avgsteps,
                        type = "l",
                        xlab = "interval",
                        ylab = "average steps",
                        main = "Time series plot of the average number of steps taken"))

# 5
as.data.frame(averagesteps[which.max(averagesteps$avgsteps), ])

# 6
na.activity <- activity[is.na(activity$steps),]
nrow(na.activity)

na.activity <-  na.activity %>% left_join(averagesteps)
na.activity$steps <- na.activity$avgsteps
na.activity <- select(na.activity, -avgsteps)

activities <- rbind(na.activity, no.na.activity)
na.totalstepsperday <- activities %>% group_by(date) %>% summarize(totalsteps = sum(steps))

# 7
hist(na.totalstepsperday$totalsteps,
     xlab = "Total Steps",
     main = "Histogram Total Steps per day")

na.mean.stepsperday <- mean(na.totalstepsperday$totalsteps)
print(paste("na.mean.stepsperday = ", na.mean.stepsperday))
na.median.stepsperday <- median(na.totalstepsperday$totalsteps)
print(paste("na.median.stepsperday = ", na.median.stepsperday))

# 8
activities$weekday <- weekdays(activities$date)
activities$weekend <- as.factor(sapply(activities$weekday, daytype))

average.steps <- activities %>% group_by(weekend, interval) %>% summarize(avgsteps = mean(steps))

xyplot(avgsteps ~ interval | weekend, 
       group = weekend, data = average.steps,
       type = c("l"),
       layout = c(1,2),
       xlab = "Interval",
       ylab = "Average Steps",
       main = "Average Steps comparisons between Weekend & Weekday")







