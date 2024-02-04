# SET COMMON VARIABLES ----

# set working directory
setwd("~/Downloads/")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  tidyverse,
  #  ggplot2,
  #  dplyr,
  #  zoo,
  #  reshape2,
  lubridate,
  #  plotly,
  #  data.table,
  #  rjson,
  ggthemes,
  #  extrafont,
  #  tidyr,
  #  ggalt,
  #  directlabels,
  #  scales,
  ggtext
)

# IMPORT DATASETS ----

df <- read.csv(file("web50repWindowsUpdateDetailsDesktop.csv"), sep = ";")

# TRANSFORM DATA ----

# create a working dataframe using the columns we need
df2 <- subset(df, select = c("AssetName", "PatchDate", "Lastseen"))

# the PatchDate column needs a nominal day setting so it can become a date value
# choosing the 15th of the month as Patch Tuesday will always have happened by then
df2$PatchDate2 <- paste("15", df2$PatchDate, sep = " ")

# now make this a date
df2$PatchDate2 <- as.Date(df2$PatchDate2, "%d %B %Y")

# the lastseen column is generally datetime but the time is not consistently formatted
#  and we don't need it, so let's split it out -
df2 <- df2 %>%
  tidyr::separate_wider_delim(Lastseen, delim = " ", names = c("lastseen_date", "lastseen_time"))

# - and delete it
df2 <- subset(df2, select = -lastseen_time)

# and now set what's left as a date
df2$lastseen_date <- as.Date(df2$lastseen_date, "%d/%m/%Y")

# get rid of any assets that haven't been seen for over ninety days
df2 <- subset(df2, lastseen_date>lubridate::today() - lubridate::days(90))
