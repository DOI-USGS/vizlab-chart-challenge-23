
library(tidyverse)
fish_data <- read_csv("in/fish_data.csv")

# change to factors 
fish_data <- fish_data|>
  mutate(species = factor(species, levels = c("American Shad", "Striped Bass")), 
         variable = factor(variable, levels = c("Onset", "Cessation", "Duration")),
         period = factor(period, levels = c("Historical", "Future")))
  

# take out duration and confidence intervals
fish_data <- fish_data[fish_data$variable %in% c("Onset", "Cessation"), ]
fish_data <- select(fish_data, -c("RCP_26_CI", "RCP_45_CI", "RCP_60_CI", "RCP_85_CI"))

# fix date column 
fish_data$origin_date <- as.Date(fish_data$origin_date, format = "%m/%d/%Y")
fish_data_long <- gather(fish_data, condition, value, RCP_26:RCP_85)
fish_data_long$end_date <- fish_data_long$origin_date + fish_data_long$value


# plotting
library(ggplot2)
theme_usgs <- function(legend.position = "right"){
  theme(
    plot.title = element_text(vjust = 3, size = 9,family="serif"),
    plot.subtitle = element_text(vjust = 3, size = 9,family="serif"),
    panel.border = element_rect(colour = "black", fill = NA, size = 0.1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    legend.background = element_blank(),
    legend.justification=c(0, 0),
    legend.position = legend.position,
    legend.key = element_blank(),
    legend.title = element_blank(),
    legend.text = element_text(size = 8),
    axis.title.x = element_text(size = 9, family="serif"),
    axis.title.y = element_text(vjust = 1, angle = 90, size = 9, family="serif"),
    axis.text.x = element_text(size = 8, vjust = -0.25, colour = "black", 
                               family="serif", margin=margin(10,5,20,5,"pt")),
    axis.text.y = element_text(size = 8, hjust = 1, colour = "black", 
                               family="serif", margin=margin(5,10,10,5,"pt")),
    axis.ticks = element_line(colour = "black", size = 0.1),
    axis.ticks.length = unit(-0.25 , "cm")
  )
}


ggplot(data = fish_data_long, aes(x = end_date, y = variable)) +
  geom_point(aes(col = condition)) + 
  facet_wrap(~species) +
  theme_usgs()


# bar plot 
y_location <- tibble(variable = rep(c("Onset", "Cessation"), 1, each =4), 
                     condition = rep(c("RCP_26", "RCP_45", "RCP_60", "RCP_85"), 2), 
                     y = rep(c(1:4) + 5, 2))

fish_data_long <- full_join(fish_data_long, y_location, by = c("variable", "condition"))

library(scales)
ggplot(data = fish_data_long) + 
  geom_segment(aes(x = origin_date, xend = end_date, y = y, yend = y, col = period, group = period), size = 10, alpha = 0.7, show.legend = FALSE) +
  # geom_segment(aes(x = as.Date("2023-01-01"), xend = as.Date("2023-12-31"), y = 3, yend = 3), col = "grey", size = 30) +
  # geom_segment(aes(x = as.Date("2023-01-01"), xend = as.Date("2023-12-31"), y = 3, yend = 3), col = "white", size = 29) +
  scale_color_brewer(palette = "Accent") +
  scale_x_date(limits = c(as.Date("2023-01-01"), as.Date("2023-12-31")), date_breaks = "1 month", date_minor_breaks = "1 week", date_labels = "%B") +
  scale_y_continuous(limits = c(0, 10)) +
  coord_polar(theta = "x", direction = 1, start = -1.57) +
  facet_wrap(~species) +
  labs(x = "", y = "") +
  theme_bw()+
  theme(axis.text.y = element_blank(), 
        axis.ticks = element_blank())

ggsave("out/ggplot_base.png", width = 16, height = 9, units = "in", dpi = 1200)
