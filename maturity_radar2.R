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
  ggtext,
  fmsb
)

# IMPORT DATA ----

# set sheet path
# workbook_path <- "j:/dma2023.xlsx"
workbook_path <- "/Users/andrewharrison/Downloads/dma2023.xlsx"
workbook_sheet <- "dma"

# import
df <- read_excel(workbook_path, sheet = workbook_sheet)

# install ggradar separately because reasons
# devtools::install_github("ricardo-bion/ggradar", dependencies = TRUE)
# library(ggradar)

# averaged radar chart ----

# create a dataframe without the capability names
by_category <- subset(df, select = c("Category", "Score", "Min", "Max"))

# group by category
# sum all the other columns (score, max and min)
# divide the score by the maxed score and multiply by five
# giving a score out of five for each category
by_category <- by_category %>% 
  group_by(Category) %>%
  summarise(across(everything(), sum, na.rm=TRUE)) %>%
  mutate(computed_score = Score / Max * 5)

# add a computed max and min score for each row
by_category$computed_max = 5
by_category$computed_min = 0

# form a separate df with only the computed numbers
df_radar <- subset(by_category, select = c("Category", "computed_max", "computed_min", "computed_score"))

# set the row names to be the values of the category column
row.names(df_radar) <- df_radar$Category[1:7]

# now transpose the df
df_radar2 <- t(df_radar)

# get the category names as a vector to use as axis titles
vl_vec <- c(df_radar$Category)

# remove the category names from the first row
df_radar2 <- df_radar2[-1,]

# set the df as a data.frame
df_radar2 <- data.frame(df_radar2)

# convert everything to numbers
df_radar2 <- sapply(df_radar2, as.numeric)

# set the df as a data.frame again
df_radar2 <- data.frame(df_radar2)

# do the radar plot
radarchart(df_radar2,
           axistype = 4,
           cglty = 1, cglcol = "gray",
           pcol = 4, plwd = 2,
           pfcol = rgb(0, 0.4, 1, 0.25),
           title = "DMA averaged score",
           vlabels = vl_vec,
           caxislabels = c(1, 2, 3, 4, 5))



# bar plot stuff ----

df_plot <- ggplot() +
  # bar chart with x and y axis
  geom_bar(data = df, aes(x=Capability, y=Score, fill=Score), stat = "identity") +
  # make the y axis show 0-5 regardless of the data
  scale_y_continuous(breaks = c(0, 1, 2, 3, 4, 5), limits = c(0,5)) +
  # title
  ggtitle("Dorset HealthCare - 2023 digital maturity assessment") +
  # facet the plot by category and give each facet its own scales
  facet_wrap( ~ Category, scales = "free") +
  # flip axis
  coord_flip() +
  # theme settings
  theme_clean() +
  theme(
    # hide the legent
    legend.position = "none",
    axis.text.x = element_text(angle = 0, size = 7, hjust = 1),
    axis.text.y = element_text(angle = 0, size = 7, hjust = 1),
    plot.title = element_text(size = 20, family = "Helvetica", face = "bold"),
    plot.subtitle = element_markdown(hjust = 0, vjust = 0, size = 11),
    plot.caption = element_text(size = 10),
    # hide axis titles
    axis.title = element_blank(),
    axis.text = element_text(size = 12))

# generate the plot
df_plot

# save the plot
ggsave("dma2023.png", width = 33.867, height = 19.05, units = "cm")
