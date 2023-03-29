# custom USGS theme for plots
# Courtesy of Brian Breaker (USGS, LMGWSC) and Lindsay Platt
theme_usgs <- function(legend.position = "right"){
  theme(
    plot.title = element_text(vjust = 3, size = 9, family="serif"),
    plot.subtitle = element_text(vjust = 3, size = 9,family="serif"),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.1),
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
    axis.ticks = element_line(colour = "black", linewidth = 0.1),
    axis.ticks.length = unit(-0.25 , "cm")
  )
}

# modifying for drought plot 
theme_usgsmod <- function(legend.position = "right"){
  theme(
    plot.title = element_text(vjust = 3, size = 16, family="serif", face = "bold", margin = margin(20, 0, 5, 0, "pt")),
    plot.subtitle = element_text(vjust = 3, size = 12, family="serif", margin = margin(0, 0, 20, 0, "pt")),
    plot.caption = element_text(color = "grey", face = "italic", margin = margin(10, 0, 10, 0, "pt")), 
    plot.margin = margin(20, 20, 140, 20, "pt"), 
    panel.border = element_rect(colour = "white", fill = NA, linewidth = 0.1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white"), #f3fcfb
    legend.background = element_blank(),
    legend.justification = c(1, 0),
    legend.position = legend.position,
    legend.key = element_blank(),
    legend.title = element_text(size = 12, family="serif", margin = margin(5, 10, 10, 5, "pt")),
    legend.text = element_text(size = 12, family="serif"),
    axis.title.x = element_text(size = 12, family="serif", hjust = 0.047, margin = margin(0, 0, 80, 0, "pt")), # to have room to plot timeline
    axis.title.y = element_text(vjust = 1.05, angle = 0, size = 12, family = "serif", margin = margin(0, -40, 0, 0, "pt")),
    axis.text.x = element_text(size = 12, vjust = 0, colour = "grey50",  
                               family = "serif", margin = margin(5, 5, 10, 5, "pt")),
    axis.text.y = element_text(size = 12, hjust = 0, colour = "grey50", 
                               family = "serif", margin = margin(5, 5, 10, 5, "pt")),
    axis.ticks = element_line(colour = "grey50", linewidth = 0.1),
    axis.ticks.length = unit(-0.25 , "cm")
  )
}

# for minor tick marks
label_at <- function(n) function(x) ifelse(x %% n == 0, x, "")
