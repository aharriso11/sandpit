# SET COMMON VARIABLES ----

# set working directory
setwd("~")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  ggplot2,
  dplyr,
  zoo,
  reshape2,
  jsonlite,
  knitr
)

df <- fromJSON("https://directory.spineservices.nhs.uk/ORD/2-0-0/roles")

df2 <- df$Roles

kable(df2, format = "markdown")
