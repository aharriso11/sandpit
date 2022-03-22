# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  httr,
  readxl,
  tidyr,
  ggplot2,
  dplyr,
  zoo,
  data.table,
  scales,
  glue,
  ggtext,
  ggthemes
)

# IMPORT DATA ----

excel_path <- "https://www.insee.fr/fr/statistiques/fichier/3698339/base-pop-historiques-1876-2018.xlsx"
GET(excel_path, write_disk("base-pop-historiques-1876-2018.xlsx", overwrite = TRUE))

# Import raw data from Excel
pop_data_raw <- read_excel("base-pop-historiques-1876-2018.xlsx", sheet = "pop_1876_2018", skip = 5) 

# MUNGE DATA ----

# rename the year columns
names(pop_data_raw)[names(pop_data_raw) == "PMUN18"] <- "2018"
names(pop_data_raw)[names(pop_data_raw) == "PMUN17"] <- "2017"
names(pop_data_raw)[names(pop_data_raw) == "PMUN16"] <- "2016"
names(pop_data_raw)[names(pop_data_raw) == "PMUN15"] <- "2015"
names(pop_data_raw)[names(pop_data_raw) == "PMUN14"] <- "2014"
names(pop_data_raw)[names(pop_data_raw) == "PMUN13"] <- "2013"
names(pop_data_raw)[names(pop_data_raw) == "PMUN12"] <- "2012"
names(pop_data_raw)[names(pop_data_raw) == "PMUN11"] <- "2011"
names(pop_data_raw)[names(pop_data_raw) == "PMUN10"] <- "2010"
names(pop_data_raw)[names(pop_data_raw) == "PMUN09"] <- "2009"
names(pop_data_raw)[names(pop_data_raw) == "PMUN08"] <- "2008"
names(pop_data_raw)[names(pop_data_raw) == "PMUN07"] <- "2007"
names(pop_data_raw)[names(pop_data_raw) == "PMUN06"] <- "2006"
names(pop_data_raw)[names(pop_data_raw) == "PSDC99"] <- "1999"
names(pop_data_raw)[names(pop_data_raw) == "PSDC90"] <- "1990"
names(pop_data_raw)[names(pop_data_raw) == "PSDC82"] <- "1982"
names(pop_data_raw)[names(pop_data_raw) == "PSDC75"] <- "1975"
names(pop_data_raw)[names(pop_data_raw) == "PSDC68"] <- "1968"
names(pop_data_raw)[names(pop_data_raw) == "PSDC62"] <- "1962"
names(pop_data_raw)[names(pop_data_raw) == "PTOT54"] <- "1954"
names(pop_data_raw)[names(pop_data_raw) == "PTOT36"] <- "1936"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1931"] <- "1931"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1926"] <- "1926"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1921"] <- "1921"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1911"] <- "1911"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1906"] <- "1906"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1901"] <- "1901"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1896"] <- "1896"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1891"] <- "1891"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1886"] <- "1886"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1881"] <- "1881"
names(pop_data_raw)[names(pop_data_raw) == "PTOT1876"] <- "1876"

# select only department 86 (Vienne)
pop_data <- pop_data_raw %>%
  filter(CODGEO=="86037" | CODGEO=="86035" | CODGEO=="86165" | CODGEO=="86140" | CODGEO=="86246" | CODGEO=="86273")

# convert wide data to long
pop_data <- gather(pop_data, year, pop, "2018":last_col())

# PLOT DATA ----

# create plot and geom
pop_plot <- ggplot() +
  geom_line(data = pop_data, aes(x = year, y = pop, group = 1), shape = 1, colour = "black") +
  xlab("Year") +
  ylab("Population") +
  facet_wrap( ~ LIBGEO, nrow = 2, scales = "free") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle=50, hjust=1))

pop_plot
