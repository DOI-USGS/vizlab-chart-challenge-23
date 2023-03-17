library(tidyverse)
# devtools::install_github("hrbrmstr/waffle")
library(waffle)
# library(treemapify)
library(hrbrthemes)
library(showtext)
library(spData)
library(sf)
library(scico)



## lets add a column in `p2_threshold_decadal_gw` using case when to then group networks by 4 contiguous U.S regions: West, Central, Midwest, East

threshold_decadal_gw_reg <- threshold_decadal_gw |>
  mutate(region = case_when(study_unit_abbreviation == 'acad'~ 'central',
                            study_unit_abbreviation == 'acfb'~ "east",
                            study_unit_abbreviation == 'albe' ~ 'east',
                            study_unit_abbreviation == 'cazb' ~ 'west',
                            study_unit_abbreviation == 'ccpt' ~ 'west',
                            study_unit_abbreviation == 'cnbr' ~ 'central',
                            study_unit_abbreviation == 'conn' ~ 'east',
                            study_unit_abbreviation == 'dlmv' ~ 'east',
                            study_unit_abbreviation == 'eiwa' ~ 'midwest',
                            study_unit_abbreviation == 'gafl' ~ 'east',
                            study_unit_abbreviation == 'grsl' ~ 'west',
                            study_unit_abbreviation == 'hpgw' ~ 'central',
                            study_unit_abbreviation == 'leri' ~ 'midwest',
                            study_unit_abbreviation == 'linj' ~ 'east',
                            study_unit_abbreviation == 'lirb' ~ 'midwest',
                            study_unit_abbreviation == 'miam' ~ 'midwest',
                            study_unit_abbreviation == 'mise' ~ 'midwest',
                            study_unit_abbreviation == 'mobl' ~ 'east', #maybe?
                            study_unit_abbreviation == 'necb' ~ 'east',
                            study_unit_abbreviation == 'nvbr' ~ 'west',
                            study_unit_abbreviation == 'ozrk' ~ 'central',
                            study_unit_abbreviation == 'podl' ~ 'east', #hmm
                            study_unit_abbreviation == 'poto' ~ 'east',
                            study_unit_abbreviation == 'pugt' ~ 'west',
                            study_unit_abbreviation == 'riog' ~ 'west',
                            study_unit_abbreviation == 'sacr' ~ 'west',
                            study_unit_abbreviation == 'sana' ~ 'west',
                            study_unit_abbreviation == 'sanj' ~ 'west',
                            study_unit_abbreviation == 'sant' ~ 'east',
                            study_unit_abbreviation == 'sctx' ~ 'central',
                            study_unit_abbreviation == 'sofl' ~ 'east',
                            study_unit_abbreviation == 'splt' ~ 'central',
                            study_unit_abbreviation == 'trin' ~ 'central',
                            study_unit_abbreviation == 'uirb' ~ 'midwest',
                            study_unit_abbreviation == 'umis' ~ 'midwest',
                            study_unit_abbreviation == 'usnk' ~ 'west',
                            study_unit_abbreviation == 'whit' ~ 'midwest',
                            study_unit_abbreviation == 'wmic' ~ 'midwest'))
# 7 central, 11 east, 10 west, 9 midwest
threshold_decadal_gw_reg_grp <- threshold_decadal_gw_reg |>
  group_by(parameter, region, bins) |>
  summarise(count_bins_sum=sum(count_bins),
            count_obs_sum = sum(count_obs))  |>
  mutate(ratio = round(count_bins_sum/count_obs_sum*100)) |>
  filter(parameter %in% c("DO", "Fe", "Li_dw", "Li_hhb", "Mo", "NO3", "Pb", "Sr")) |>
  #capitalize regions
  mutate(region = str_to_title(gsub(",", " ", region))) |>
  arrange(match(bins, c("high", "moderate", "low")))

## sf regions
tar_load(wells_centroid_csv)
wells_centroid <-readr::read_csv(wells_centroid_csv,show_col_types = FALSE)  |>
  janitor::clean_names() |>
  filter(!is.na(longitude_nad83_dd)) |>
  sf::st_as_sf(coords = c("longitude_nad83_dd", "latitude_nad83_dd"), crs = "epsg:4269") |>
  rename(su_code = network)

threshold_decadal_gw_reg_grp_sf <- threshold_decadal_gw_reg |>
  left_join(wells_centroid, by = c("su_code")) |>
  dplyr::select(su_code, region, geometry) |>
  st_as_sf(crs = "epsg:4269") |>
  filter(region %in% "east")

states <- spData::us_states |> st_transform(crs = st_crs(wells_centroid)) |>
  st_crop(threshold_decadal_gw_reg_grp_sf)

ggplot() +
  geom_sf(data = states,
          fill = NA,
          color = 'black',
          linewidth = 0.3) +
  geom_sf(data = threshold_decadal_gw_reg_grp_sf,
          fill = '#e45c5c',
            color = '#e45c5c',
          size = 1.5,
          alpha = 0.5) +
  theme_void()

ggsave(file = paste0("out/east_networks", ".svg"),
       width = 1.2,
       height = 1.2,
       units = "in",
       bg = "white")

# import fonts
font_legend <- 'Merriweather Sans'
font_add_google(font_legend)
showtext_opts(dpi = 300, regular.wt = 300, bold.wt = 800)
showtext_auto(enable = TRUE)

uniq_parms <- unique(threshold_decadal_gw_reg_grp$parameter)

# run for loop to output svg waffle charts for each constituent faceted by region
for (i in seq_along(uniq_parms)) {
    data=subset(
      threshold_decadal_gw_reg_grp,
      parameter==uniq_parms[[i]]
    )
    if (nrow(data) == 0) {
      next
    }

# waffle charts - but! theres a bug, cant facet_grid :( see here: https://github.com/hrbrmstr/waffle/issues/66
plt <- ggplot(data, aes(values = ratio, fill = bins)) +
  geom_waffle(color = "white", size=1.125, n_rows = 10,
              make_proportional = TRUE,
              stat = "identity") +
  facet_wrap(~factor(region, levels = c("West", "Central", "Midwest", "East"))) +
  coord_equal() +
  scale_x_discrete(expand=c(0,0)) +
  scale_y_discrete(expand=c(0,0)) +
  scale_fill_manual(name=NULL, values = c("#556240", "#819561","#b9c5a6"), breaks=c('high', 'moderate', 'low'), labels = c("High concentration", "Moderate concentration", "Low concentration")) +
  labs(
    title = paste(uniq_parms[i]),
    subtitle = "Proportion of study area"
  ) +
  theme_void() +
      theme(strip.text = element_text(size = 26,
                                      margin=margin(b=5)),
            legend.key.width = unit(0.75, "cm"),
            legend.text = element_text(size = 16),
            legend.title = element_text(size = 26),
            legend.direction = "horizontal",
            legend.position = "top",
            text = element_text(size=22,family = font_legend, color = "black", face= "bold"),
            plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5, size = 20)) +
      guides(fill = guide_legend(title.position = "top", title.hjust=0.5))
  # geom_text(aes(x= 2, y=1, fill = factor(bins, levels = c('high', 'moderate', 'low')), group = bins, label= paste0(ratio, "%")),
  #           position = position_dodge(width = 4),
  #           size=5,
  #           color = "black", show.legend = F,
  #           ylim = c(1, NA),
  #           family = font_legend,
  #           fontface = 'bold')

    ggsave(file = paste0("out/","region", "_", uniq_parms[i], ".svg"), plot = plt,
           width = 12,
           height = 12,
           units = "in",
           bg = "white")
  }
