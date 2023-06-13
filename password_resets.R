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
  ggthemes,
  splitstackshape,
  data.table
)

# IMPORT DATA ----

# read in the csv file
df <- read.csv(file = "resets.csv")


# TRANSFORM DATA ----

# remove computer account password resets
df <- df %>%
  filter(src_user_name != "SVC_JOIN")

# the date/time stamp from Splunk is very detailed, it's simpler to split this using "T" as a demlimiter
df2 <- cSplit(df, "X_time", "T")

# Now we have X_time_1 and X_time_2. We don't need _2 so we'll subset the columns to get rid of it.
df2 <- subset(df2, select = c("Target_User_Name","src_user_name","EventCode","X_time_1"))

# X_time_1 is text so we need to specify it as a date
df2$X_time_1 <- as.Date(df2$X_time_1, "%Y-%m-%d")

# create a new dataframe and use a dplyr pipeline to
# count the number of occurrences of a date
df3 <- df2 %>%
  group_by(EventCode) %>%
  count(X_time_1)

# because we want to group by day of the week, use wday to add this as a new column
# data.table (required for cSplit above) also has a function called wday so we need to specify
# the library (Lubridate) that it comes from
df3$Day <- lubridate::wday(df3$X_time_1, label=TRUE, abbr=FALSE)

# optional!
df3 <- subset(df3, X_time_1 > "2022-10-17")


# PLOT DATA IN GGPLOT

df_plot <- ggplot() +
  # create a column chart using df2 with our new Day column defining how the objects get filled
  geom_col(data = df3, aes(x = X_time_1, y = n, fill = Day)) +
  # set the x axis labels
  scale_x_date(date_labels = "%a %d %b %y", date_breaks = "1 day") +
  # set axis titles
  xlab("Date") +
  ylab("Number") +
  # give the plot a title
  ggtitle("Domain password changes and resets") +
  facet_grid( ~ EventCode) +
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
ggsave("expiry_actual.png", width = 16.6, height = 8.65, units = "in")
