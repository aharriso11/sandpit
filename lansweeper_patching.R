# SET COMMON VARIABLES ----

# set working directory
setwd("~/Downloads/")

# disable scientific notation
options(scipen=999)

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  tidyverse,
  #  ggplot2,
  #  dplyr,
  #  zoo,
  reshape,
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

dfd <- read.csv(file("web50repWindowsUpdateDetailsDesktop.csv"), sep = ";")

dfs <- read.csv(file("web50repWindowsUpdateDetailsServer.csv"), sep = ";")

# TRANSFORM DATA - DESKTOPS AND LAPTOPS ----

# create a working dataframe using the columns we need
dfd2 <- subset(dfd, select = c("AssetName", "PatchDate", "Lastseen"))

# the PatchDate column needs a nominal day setting so it can become a date value
# choosing the 15th of the month as Patch Tuesday will always have happened by then
dfd2$PatchDate2 <- paste("15", dfd2$PatchDate, sep = " ")

# now make this a date
dfd2$PatchDate2 <- as.Date(dfd2$PatchDate2, "%d %B %Y")

# the lastseen column is generally datetime but the time is not consistently formatted
#  and we don't need it, so let's split it out -
dfd2 <- dfd2 %>%
  tidyr::separate_wider_delim(Lastseen, delim = " ", names = c("lastseen_date", "lastseen_time"))

# - and delete it
dfd2 <- subset(dfd2, select = -lastseen_time)

# and now set what's left as a date
dfd2$lastseen_date <- as.Date(dfd2$lastseen_date, "%d/%m/%Y")

# get rid of any assets that haven't been seen for over ninety days
dfd2 <- subset(dfd2, lastseen_date>lubridate::today() - lubridate::days(90))

# count each occurrence of a month
dfd3 <- dfd2 %>%
  dplyr::count(PatchDate2)

# calculate a percentage for each one
dfd3$desktop_per <- dfd3$n / sum(dfd3$n) * 100

# and add a month and year label column for each month
dfd3$Month_Yr <- format(as.Date(dfd3$PatchDate2), "%B %Y")


# TRANSFORM DATA - SERVERS ----

# create a working dataframe using the columns we need
dfs2 <- subset(dfs, select = c("AssetName", "PatchDate", "Lastseen"))

# the PatchDate column needs a nominal day setting so it can become a date value
# choosing the 15th of the month as Patch Tuesday will always have happened by then
dfs2$PatchDate2 <- paste("15", dfs2$PatchDate, sep = " ")

# now make this a date
dfs2$PatchDate2 <- as.Date(dfs2$PatchDate2, "%d %B %Y")

# the lastseen column is generally datetime but the time is not consistently formatted
#  and we don't need it, so let's split it out -
dfs2 <- dfs2 %>%
  tidyr::separate_wider_delim(Lastseen, delim = " ", names = c("lastseen_date", "lastseen_time"))

# - and delete it
dfs2 <- subset(dfs2, select = -lastseen_time)

# and now set what's left as a date
dfs2$lastseen_date <- as.Date(dfs2$lastseen_date, "%d/%m/%Y")

# get rid of any assets that haven't been seen for over ninety days
dfs2 <- subset(dfs2, lastseen_date>lubridate::today() - lubridate::days(90))

# count each occurrence of a month
dfs3 <- dfs2 %>%
  dplyr::count(PatchDate2)

# calculate a percentage for each one
dfs3$server_per <- dfs3$n / sum(dfs3$n) * 100

# and add a month and year label column for each month
dfs3$Month_Yr <- format(as.Date(dfs3$PatchDate2), "%B %Y")





#merge datasets into one
df3_list <- list(dfd3, dfs3)
df3_combined <- reshape::merge_recurse(df3_list)





plot <- ggplot2::ggplot() +
  geom_bar(data = df3, aes(x = , y = per, fill = PatchDate2), position = "fill", stat = "identity")

plot
