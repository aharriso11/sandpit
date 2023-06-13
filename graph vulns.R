# create a new dataframe and use a dplyr pipeline to
# count the number of occurrences of a date
df <- data_arranged %>%
  group_by(HOST) %>%
  dplyr::count(RISK)

df2 <- data_arranged %>%
  dplyr::count(HOST) %>%
  arrange(desc(n))

df$RISK <- factor(df$RISK, levels = c("Low", "Medium", "High", "Critical"))

df$HOST <- reorder(df$HOST, df$n, sum)

df_plot <- ggplot() +
  geom_bar(data = df, aes(x = n, y = HOST, fill = RISK), position = "stack", stat = "identity") +
  scale_fill_manual(name = "Risk", values = c("Critical" = "purple", "High" = "red", "Medium" = "orange", "Low" = "blue")) +
  xlab("Vulnerabilities") +
  ylab("Host") +
  theme_base()

df_plot

ggsave("backup_devices.png", width = 16.6, height = 8.65, units = "in")
