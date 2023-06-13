# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/sandpit")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  httr,
  readxl,
  readODS,
  tidyverse,
  zoo,
  data.table,
  scales,
  glue,
  ggtext,
  ggthemes,
  pals,
  utils,
  reshape,
  lubridate,
  stringr
)

# DOWNLOAD DATA ----

# set mobility reports zipfile path
zip_path_2010_2011 <- "https://files.digital.nhs.uk/B1/30CE7B/SHMI%20data%20files%2C%20Apr10-Mar11.zip"
zip_path_2011_2012 <- "https://files.digital.nhs.uk/D9/A9CD1E/SHMI%20data%20files%2C%20Apr11-Mar12.zip"
zip_path_2012_2013 <- "https://files.digital.nhs.uk/DD/0862E7/SHMI%20data%20files%2C%20Apr12-Mar13.zip"
zip_path_2013_2014 <- "https://files.digital.nhs.uk/36/991301/SHMI%20data%20files%2C%20Apr13-Mar14.zip"
zip_path_2014_2015 <- "https://files.digital.nhs.uk/DD/54895D/SHMI%20data%20files%2C%20Apr14-Mar15.zip"
zip_path_2015_2016 <- "https://files.digital.nhs.uk/99/A1000C/SHMI%20data%20files%2C%20Apr15-Mar16.zip"
zip_path_2016_2017 <- "https://files.digital.nhs.uk/12/2EDA70/SHMI%20data%20files%2C%20Apr16-Mar17.zip"
zip_path_2017_2018 <- "https://files.digital.nhs.uk/AA/8C96CC/SHMI%20data%20files%2C%20Apr17-Mar18.zip"
zip_path_2018_2019 <- "https://files.digital.nhs.uk/E7/6314D8/SHMI%20data%20files%2C%20Apr18-Mar19.zip"
zip_path_2019_2020 <- "https://files.digital.nhs.uk/8C/4AADFC/SHMI%20data%20files%2C%20Apr19-Mar20.zip"
zip_path_2020_2021 <- "https://files.digital.nhs.uk/5F/CCBBB6/SHMI%20data%20files%2C%20Apr20-Mar21.zip"

zip_file_2010_2011 <- str_sub(zip_path_2010_2011, -40)
zip_file_2011_2012 <- str_sub(zip_path_2011_2012, -40)
zip_file_2012_2013 <- str_sub(zip_path_2012_2013, -40)
zip_file_2013_2014 <- str_sub(zip_path_2013_2014, -40)
zip_file_2014_2015 <- str_sub(zip_path_2014_2015, -40)
zip_file_2015_2016 <- str_sub(zip_path_2015_2016, -40)
zip_file_2016_2017 <- str_sub(zip_path_2016_2017, -40)
zip_file_2017_2018 <- str_sub(zip_path_2017_2018, -40)
zip_file_2018_2019 <- str_sub(zip_path_2018_2019, -40)
zip_file_2019_2020 <- str_sub(zip_path_2019_2020, -40)
zip_file_2020_2021 <- str_sub(zip_path_2020_2021, -40)

files <- data.frame(
  zip_path = c(zip_path_2010_2011, zip_path_2011_2012, zip_path_2012_2013, zip_path_2013_2014, zip_path_2014_2015, zip_path_2015_2016, zip_path_2016_2017, zip_path_2017_2018, zip_path_2018_2019, zip_path_2019_2020, zip_path_2020_2021),
  zip_file = c(zip_file_2010_2011, zip_file_2011_2012, zip_file_2012_2013, zip_file_2013_2014, zip_file_2014_2015, zip_file_2015_2016, zip_file_2016_2017, zip_file_2017_2018, zip_file_2018_2019, zip_file_2019_2020, zip_file_2020_2021)
)


# set downloaded file path and name for downloaded data
file_name <- "temp/SHMI%20data%20files%2C%20Nov20-Oct21.zip"

# download the SHMI zipfile
GET(files$zip_path[1-11], write_disk(file_name, overwrite = TRUE))

# extract the GB data
unzip(file_name, files = c("SHMI data/SHMI data at trust level, Nov20-Oct21 (csv).csv"), overwrite = TRUE, exdir = "./temp/", junkpaths = TRUE)

# import the data
files <- list.files(path = "./temp/", pattern = ".csv")

shmi <- read.csv(paste0("temp/", files[1]))
