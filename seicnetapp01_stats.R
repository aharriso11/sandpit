# SET COMMON VARIABLES ----

# set working directory
setwd("c:/b/")

# LOAD LIBRARIES ----

# Install the pacman package to call all the other packages
if (!require("pacman")) install.packages("pacman")

# Use pacman to install (if req) and load required packages
pacman::p_load(
  #ggplot2,
  #dplyr,
  zoo,
  lubridate,
  #devtools,
  tidyverse,
  ggthemes,
  #splitstackshape,
  #data.table,
  scales,
  viridis
  #R.utils
)


# IMPORT DATA ----

# SEICAPP01 - sensor id 59553
df_seicapp01 <- read.csv(url("https://srprtg01.dhc.nhs.uk/api/historicdata.csv?id=64138&avg=3600&sdate=2024-06-10-00-00-00&edate=2024-06-24-00-00-00&username=it3l&passhash=59896951"))

# SEEPMAWEBL02 - sensor id 64168
# df_seepmawebl02 <- read.csv(url("https://srprtg01.dhc.nhs.uk/api/historicdata.csv?id=64168&avg=3600&sdate=2024-02-22-00-00-00&edate=2024-03-08-00-00-00&username=it3l&passhash=59896951"))


df_seicapp01 <- subset(df_seicapp01, select = c("Date.Time.RAW.", "Connections.RAW.", "Downtime.RAW."))
# df_seepmawebl02 <- subset(df_seepmawebl02, select = c("Date.Time.RAW.", "Connections.RAW.", "Downtime.RAW."))

names(df_seicapp01)[names(df_seicapp01) == "Connections.RAW."] <- "seicapp01"
names(df_seicapp01)[names(df_seicapp01) == "Downtime.RAW."] <- "Downtime"
# names(df_seepmawebl02)[names(df_seepmawebl02) == "Connections.RAW."] <- "seepmawebl02"
# names(df_seepmawebl02)[names(df_seepmawebl02) == "Downtime.RAW."] <- "Downtime_2"

df_work <- df_seicapp01

#df_work$seepmawebl02 <- with(df_seepmawebl02, seepmawebl02[match(df_work$Date.Time.RAW., Date.Time.RAW.)])
#df_work$Downtime_2 <- with(df_seepmawebl02, Downtime_2[match(df_work$Date.Time.RAW., Date.Time.RAW.)])

df_work$datetimestamp <- as.POSIXlt(x = df_work$Date.Time.RAW. * 86400, origin = "1899-12-30")

df_work$datetimefinal <- as_datetime(as.character(as.POSIXlt(df_work$datetimestamp)))

df_work$uptime <- 100-(df_work$Downtime)

df_work_long <- subset(df_work, select = c("datetimefinal", "seicapp01"))
  
df_work_long <- tidyr::gather(df_work_long, Host, conns, seicapp01)


plot <- ggplot() +
  geom_line(data = df_work, aes(x=datetimefinal, y=uptime, colour= "red3"), size = 2) +
  geom_area(data = df_work_long, aes(x = datetimefinal, y = conns, group = Host, fill = Host), position = "stack") +
  scale_y_continuous(breaks = c(20, 40, 60, 80, 100), limits = c(0,100), expand = expansion(mult = c(0, 0.08))) +
  scale_x_datetime(breaks = "1 day", expand = expansion(mult = c(0, 0))) +
  scale_fill_manual(name = "Host", values = c("seicapp01" = "turquoise4"), labels = c("seicapp01")) +
  scale_colour_manual(name = "Uptime", values = c("red3" = "red3"), labels = c("Uptime percent")) +
  xlab("Date") +
  ylab("Connections and uptime percentage") +
  ggtitle("ICnet application connections and uptime") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 25, size = 12, hjust = 1),
    plot.title = element_text(size = 20, family = "Arial", face = "bold"),
  )

plot

ggsave("seicapp01_uptime.png", width = 20, height = 10, units = "cm")
