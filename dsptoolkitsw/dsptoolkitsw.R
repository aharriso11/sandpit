# SET COMMON VARIABLES ----

# set working directory
setwd("~/Documents/GitHub/sandpit/dsptoolkitsw")

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
  rvest
)


# DOWNLOAD DATA ----

# set report zipfile paths
etr_path <- "https://files.digital.nhs.uk/assets/ods/current/etr.zip"
eccg_path <- "https://files.digital.nhs.uk/assets/ods/current/eccg.zip"

# set report zipfile names
etr_file <- "temp/etr.zip"
eccg_file <- "temp/eccg.zip"

# download the report zipfiles
GET(etr_path, write_disk(etr_file, overwrite = TRUE))
GET(eccg_path, write_disk(eccg_file, overwrite = TRUE))

# extract files
unzip(etr_file, files = c("etr.csv"), overwrite = TRUE, exdir = "./temp/")
unzip(eccg_file, files = c("eccg.csv"), overwrite = TRUE, exdir = "./temp/")

# IMPORT DATA ----

# import ETR dataframe
df_etr <- read.csv(file = "temp/etr.csv", header = FALSE)

# import CCG dataframe
df_eccg <- read.csv(file = "temp/eccg.csv", header = FALSE)

# MUNGE DATA ----

# merge dfs together
df_bind <- rbind(df_etr, df_eccg)

# filter to include organisations with V3 value of Y58 (SW region)
# do not include organisations with V4 value of Q99 
df_bind <- df_bind %>%
  filter(V3 == "Y58" & V4 != "Q99")

df_bind$url <- paste0("https://www.dsptoolkit.nhs.uk/OrganisationSearch/", df_bind$V1)

fn_scrapenwrite <- function(x, output) {
  
  scrapeurl = x[28]
  
  writeurl = x[1]

  scrape <- read_html(scrapeurl)

  dspts <- scrape %>%
    html_nodes(xpath='//*[@id="orgSearchDetailsPublications"]') %>%
#    add_column(ods = "RDY") %>%
    html_table()

#  dspts <- dspts[[1]]

  dspts$ods <- writeurl
    
  }

apply(df_bind, 1, fn_scrapenwrite )









func <- function(x, output ) {
  
scrapeurl = x[28]
  
writeurl = x[1]
  
  scrape <- read_html(scrapeurl)
  
  dspts <- scrape %>%
    html_nodes(xpath='//*[@id="orgSearchDetailsPublications"]') %>%
    html_table()
  
dspts$ods <- writeurl

return(dspts)

}

func("https://www.dsptoolkit.nhs.uk/OrganisationSearch/RDY", "RDY")

d <- apply(df_bind, 1, func )

e <- unlist(d, recursive = TRUE, use.names = TRUE)

f <- bind_rows(d)

f <- f %>%
  fill(V1, .direction = "up") %>%
  drop_na(Status)

f <- subset(f, select = c("Status", "Date Published", "V1"))
