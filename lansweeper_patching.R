# SET COMMON VARIABLES ----

# set working directory
setwd("c:/users/andrewh/Downloads/")

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
  scales,
  ggtext,
  pals
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

# tidy up NAs
dfd3 <- na.omit(dfd3)

# calculate a percentage for each one
dfd3$Endpoint <- dfd3$n / sum(dfd3$n) * 100

# and add a month and year label column for each month
dfd3$Month <- format(as.Date(dfd3$PatchDate2), "%B %Y")


endpoint_per_marker <- sum(tail(dfd3$Endpoint, 3))

dfd3$marker <- endpoint_per_marker

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

# tidy any NAs
dfs3 <- na.omit(dfs3)

# calculate a percentage for each one
dfs3$Server <- dfs3$n / sum(dfs3$n) * 100

# and add a month and year label column for each month
dfs3$Month <- format(as.Date(dfs3$PatchDate2), "%B %Y")

server_per_marker <- sum(tail(dfs3$Server, 3))

dfs3$marker <- server_per_marker






#merge datasets into one
df3_list <- list(dfd3, dfs3)
df3_combined <- reshape::merge_recurse(df3_list)


df4 <- tidyr::gather(df3_combined, estate, per, Endpoint:Server, na.rm = TRUE)

df4 <- df4 %>%
  dplyr::arrange(desc(PatchDate2))

legend_ord <- levels(with(df4, stats::reorder(Month, PatchDate2, decreasing=TRUE)))

plot <- ggplot2::ggplot(df4, aes(x = estate, y = per)) +
  geom_col(data = df4, aes(fill = Month, group = PatchDate2)) +
   scale_fill_manual(breaks = legend_ord, values=rev(ocean.haline(20))) +
##  scale_fill_manual(breaks = legend_ord, values=rev(viridis(26))) +
# # scale_y_continuous(breaks = 0, 25, 50, 75, 85, 100) +
  geom_hline(yintercept = 80, linetype = "solid", colour = "black", size = 1.5) +
  geom_text(aes(label = Month), position = "stack", size = 3.5, angle = 90, vjust = -0.35) +
  geom_errorbar(aes(ymax = marker, ymin = marker), colour = "red", size = 1.5, linetype = "solid") +
  xlab("Estate") +
  ylab("Percentage of estate") +
  coord_flip() +
  ggtitle("Windows estate - security patching uptake") +
  labs(subtitle = "This chart shows the uptake of security patches across our Windows IT estate. <br> We aim to have eighty per cent of the estate (shown by a thick black line) <br> covered by a security update that has been released in the past three months (red line).", caption = paste("Data from Lansweeper. Plotted", Sys.time(), sep = " ")) +
  theme_clean() +
  theme(
    plot.subtitle = element_markdown(size = 10),
    plot.caption = element_markdown(size = 8),
    legend.text = element_text(size = 9)
  )

plot

ggsave("patching.png", width = 20, height = 15, units = "cm")
