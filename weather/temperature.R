# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/sandpit/weather")

# disable scientific notation
options(scipen=999)

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  tidyverse,
  scales,
  ggtext,
  ggthemes,
  lubridate,
  rjson,
  jsonlite,
  data.table
)

# IMPORT DATASETS ----

# encode url for temperature data
# url needs to be encoded so we can use it with fromJSON
# change this to suit the URL of your Cumulus MX environment
temp_json_url <- URLencode('http://raspberrypi:8998/api/graphdata/tempdata.json')

# get all temperature data
temp_json_data <- fromJSON(temp_json_url)

# extract outside temperature data and place it in a dataframe named temp_df
temp_df <- data.table(temp_json_data[["temp"]])

# give the columns of temp_df useful names
colnames(temp_df) <- c("timestamp","temperature")

# the timestamp column uses the Unix timestamp down to milliseconds
# as there is only one observation per minute we can take this down to seconds
# we do this by dividing the timestamp by 1000
temp_df <- temp_df %>%
  mutate(timestamp = timestamp / 1000)

# convert the timestamp to a human readable date and time
temp_df$datetime <- as.POSIXct(temp_df$timestamp, origin = "1970-01-01")

df_plot <- ggplot() +
  geom_line(data = temp_df, aes(x=datetime, y=temperature), colour = "royalblue", size = 0.75) +
  scale_x_datetime(breaks = "4 hours") +
  xlab("Date and time") +
  ylab("Temperature (C)") +
  ggtitle("Outdoor temperature at the DT3 115m asl weather station") +
  theme_clean() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10)
  )

df_plot
