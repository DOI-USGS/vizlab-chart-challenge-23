##############
# Main Viz Script
##############

# source ------------------------------------------------------------------

source('prep/3_LT_streamflow_data_processing.R')

# Viz Variables -----------------------------------------------------------

map_bbox <- st_bbox(Lake_Tahoe_huc8)


# Map ---------------------------------------------------------------------

LT_map <- ggplot()+
  geom_sf(data = West_sf, fill = 'white', color = 'grey', alpha = 0.1, size = 0.5)+
  geom_sf(data = LT_lakes, fill = '#3792cb', color = '#3792cb', alpha = 0.8)+
  geom_sf_text(data = West_sf, color = 'grey', aes(label = NAME), size =2, fontface = 'italic', nudge_x = 0.1) +
  geom_sf(data = Lake_Tahoe_huc8, fill = 'transparent', color = 'firebrick', size = 0.8, linetype = 'dotted')+
  geom_sf(data = LT_flines_3, color = '#3792cb', size  = 0.5, alpha = 0.6)+
  geom_sf(data = active_nwis_sites_lake_tahoe,
          aes(geometry = geometry),
          color = '#006200',
          size = 1.3, alpha = 0.9)+
  geom_sf_text(data = active_nwis_sites_lake_tahoe, color = 'black',
               aes(label = site_no), size =3, nudge_x = 0.05) +
  coord_sf(ylim = c(map_bbox$ymin, map_bbox$ymax),
           xlim = c(map_bbox$xmin, map_bbox$xmax))+
  theme_classic()+
  theme(plot.title = element_text(size = 10, face= 'bold'),
        legend.text = element_text (size = 10),
        legend.title = element_text (size = 12),
        axis.title.x = element_blank(),
        axis.line = element_blank(),
        panel.background = element_rect(color= 'black'),
        axis.title.y = element_blank(),
        legend.position = 'bottom', 
        axis.text = element_blank(),
        axis.ticks = element_blank()
        )

ggsave('out/LT_map_gauges.png', width = 9, height = 9, dpi = 300)

# Plot --------------------------------------------------------------------

## quick plot (filtered only to monday to make plot less busy - still need to work on this      

lapply(active_sites_2023,
       function(x){
         LT_dv_data_w_MA |> 
           filter(day_of_week == 'Mon',
                  site_no == x) |>
           ggplot(aes(x = Date, y = MA))+
           geom_line(aes(color = site_no))+
           theme_classic()+
           labs(title = sprintf('Site Number: %s', x))
         ggsave(sprintf('out/ts_%s.png',x), width = 9, height = 9, dpi = 300)
       }
)


### TEMP

site <- "103366092"

## temp - like above: 
LT_dv_data_w_MA |> 
  mutate(year = as.factor(year)) |> 
  filter(day_of_week == 'Mon',
         site_no == site) |>
  ggplot(aes(x = Date, y = MA))+
  geom_line(aes(color = site_no))+
  theme_classic()+
  labs(title = sprintf('Site Number: %s', site))

## temp - split by year
LT_dv_data_w_MA |> 
  mutate(year = as.factor(year)) |> 
  filter(year %in% c(2010,2015,2020,2022,2023),
         day_of_week == 'Mon',
         site_no == site) |>
  ggplot(aes(x = month_day, y = MA))+
  geom_line(aes(color = as.factor(year)))+
  theme_classic()+
  labs(title = sprintf('Site Number: %s', site))
