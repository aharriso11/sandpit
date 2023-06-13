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
  jsonlite
)

df <- fromJSON("https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations?PrimaryRoleId=RO197&Limit=1000")

df2 <- as.data.frame(df$Organisations)

df2 <- df2 %>%
  filter(Status=="Active")

write.csv(df2, file = "RO197.csv", row.names = FALSE)
