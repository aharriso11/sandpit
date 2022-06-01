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
  tidyverse,
  ggthemes
)

# IMPORT DATA ----

# read in the csv file
df <- read.csv(file = "expiry.csv")


# TRANSFORM DATA ----

# expirydate is read in as text so we need to specify it as a date
df$ExpiryDate <- as.Date(df$ExpiryDate, "%d/%m/%Y %H:%M:%S")

# create a new dataframe and use a dplyr pipeline to
# 1) use a filter to use dates today and in the future only
# (the today() function comes from Lubridate)
# 2) count the number of occurrences of a date
df2 <- df %>%
  filter(ExpiryDate >= today()) %>%
  count(ExpiryDate)

# because we want to group by day of the week, use wday to add this as a new column
df2$Day <- wday(df2$ExpiryDate, label=TRUE, abbr=FALSE)


# PLOT DATA IN BASE PLOT ----

# just hacking around with this, ggplot is better
# first of all open a png file device
png("password_expiry.png", width = 1280, height = 768)
# x axis, y axis, suppress x axis scale, line chart
plot(df2$ExpiryDate, df2$n, xaxt = "n", type = "h",
     col = "red", #colour
     lwd = 3,     # line width
     main = "Domain forecast password expiry dates", #title
     xlab = "Date", # x axis label
     ylab = "Passwords expiring") # y axis label
# separate command to create x axis scale (I googled this)
axis(1, df2$ExpiryDate, format(df2$ExpiryDate, "%a %d %b %y"), cex.axis = .8)

# close the file device
dev.off()


# PLOT DATA IN GGPLOT

df_plot <- ggplot() +
  # create a column chart using df2 with our new Day column defining how the objects get filled
  geom_col(data = df2, aes(x = ExpiryDate, y = n, fill = Day)) +
  # set the x axis labels
  scale_x_date(date_labels = "%a %d %b %y", date_breaks = "1 day") +
  # set axis titles
  xlab("Expiry date") +
  ylab("Number of passwords expiring") +
  # give the plot a title
  ggtitle("Domain forecast password expiry dates") +
  # set a theme - I usually use the base theme
  theme_base() +
  # customise the theme
  theme(
    # turn our x axis text through 45 degrees and manually size and right-justify it
    axis.text.x = element_text(angle = 45, size = 8, hjust = 1),
    # set size and font for the plot title
    plot.title = element_text(size = 20, family = "Arial", face = "bold")
  )

# now draw the plot
df_plot

# SAVE OUTPUT ----

# save to daily file - ggsave saves the last drawn plot by default
# you can uses pixels here but it sometimes produces some strange effects
ggsave("expiry2.png", width = 16.6, height = 8.65, units = "in")
