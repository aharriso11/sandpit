# SET COMMON VARIABLES ----

# set working directory
setwd("C:/b/")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  dplyr,
  zoo,
  lubridate,
  devtools,
  tidyverse
)

# read in the csv file
df <- read.csv(file = "expiry.csv")

# expirydate is read in as text so we need to specify it as a date
df$ExpiryDate <- as.Date(df$ExpiryDate, "%d/%m/%Y %H:%M:%S")

# create a new dataframe and use a dplyr pipeline to
# 1) use a filter to use dates today and in the future only
# (the today() function comes from Lubridate)
# count the number of occurrences of a date
df2 <- df %>%
  filter(ExpiryDate >= today()) %>%
  count(ExpiryDate)

# just hacking around so I will use R base plot as opposed to ggplot
# first of all open a png file device
png("password_expiry.png", width = 1280, height = 768)
# x axis, y axis, suppress x axis scale, line chart
plot(df2$ExpiryDate, df2$n, xaxt = "n", type = "l",
     col = "red", #colour
     lwd = 3,     # line width
     main = "Forecast password expiry dates", #title
     xlab = "Date", # x axis label
     ylab = "Passwords expiring") # y axis label
# separate command to create x axis scale (I googled this)
axis(1, df2$ExpiryDate, format(df2$ExpiryDate, "%d %b %y"), cex.axis = .8)

# close the file device
dev.off()
