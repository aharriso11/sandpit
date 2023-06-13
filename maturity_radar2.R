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
  data.table,
  scales,
  R.utils,
  readxl,
  ggtext
)

# IMPORT DATA ----

# set sheet path
workbook_path <- "j:/dma2023.xlsx"
workbook_sheet <- "dma"

# import
df <- read_excel(workbook_path, sheet = workbook_sheet)

# install ggradar separately because reasons
devtools::install_github("ricardo-bion/ggradar", dependencies = TRUE)
library(ggradar)

radarchart(df,
           axistype = 4,
           cglty = 1, cglcol = "gray",
           pcol = 4, plwd = 2,
           pfcol = rgb(0, 0.4, 1, 0.25),
           caxislabels = c(1, 2, 3, 4, 5))
