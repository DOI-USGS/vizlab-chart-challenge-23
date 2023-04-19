#' Plot map
#'
#' Plot static map for given year (single frame in animation).
#'
#' @param basemap Basemap raster.
#' @param fire_pts Fire occurrence points.
#' @param year Year of fire occurrences to plot.
#' @param col_fire Color of the fire points.
#' @param font_year Font name for the printed year.
#'
build_map <- function(basemap, fire_pts, year, col_fire, font_year) {

  # Prep fonts
  showtext_opts(dpi = 300)
  showtext_auto(enable = TRUE)

  # Load basemap
  basemap <- rast(basemap)

  # Filter fire points to given year
  fire_pts_year <- fire_pts %>%
    filter(Year_month == year)

  # Filter fire points to all years prior to given year
  fire_pts_past <- fire_pts %>%
    filter(Year_month < year & Year_month > (year - 3))

  # Plotting
  ggplot() +
    # Plot basemap
    geom_spatraster_rgb(data = basemap) +

    # Plot dark glowpoints for previously burned areas
    geom_glowpoint(
      data = fire_pts_past,
      aes(x = lon, y = lat, size = BurnBndAc),
      alpha = .1,
      color = "#45220f",
      shadowcolour = "#45220f",
      shadowalpha = .05,
      show.legend = FALSE
    ) +
    scale_size(range = c(.05, 0.5)) +
    new_scale("size") +

    # Plot glowpoints for current year
    geom_glowpoint(
      data = fire_pts_year,
      aes(x = lon, y = lat, size = BurnBndAc),
      alpha = .8,
      color = col_fire,
      shadowcolour = col_fire,
      shadowalpha = .1,
      show.legend = FALSE
    ) +
    scale_size(range = c(.08, 0.6)) +
    new_scale("size") +
    geom_glowpoint(
      data = fire_pts_year,
      aes(x = lon, y = lat, size = BurnBndAc),
      alpha = .6,
      shadowalpha = .05,
      color = "#ffffff",
      show.legend = FALSE
    ) +
    scale_size(range = c(.01, .2)) +

    # Styling
    theme_void()
}


#' Plot chart
#'
#' Plot static graph for given year
#'
#' @param chart_data Vata frame for the chart data.
#' @param col_lines Vector (length = 2) of colors for the graph lines.
#' @param year Year to highlight in chart.
#' @param font_chart_titles Font name for the chart titles (facet strip text)
#' @param font_chart_axes Font name for axis lables
#'
build_graph <- function(chart_data, col_lines, year, font_chart_titles,
                        font_chart_axes) {

  # Prep fonts
  showtext_opts(dpi = 300)
  showtext_auto(enable = TRUE)

  # Filter fire points to given year
  chart_data_point <- chart_data %>%
    filter(Year == year)

  # Plotting
  ggplot() +
    # Plot line graph
    geom_glowline(
      data = chart_data, aes(x = Year, y = value, color = name),
      size = 0.4
    ) +
    scale_color_manual(values = col_lines) +
    new_scale_color() +
    # Plot points with alternated Year column
    # (so entire lines are static and only point moves)
    geom_glowpoint(
      data = chart_data_point,
      aes(x = Year, y = value, color = name), size = 0.2
    ) +

    # Styling
    scale_color_manual(values = lighten(col_lines, 0.8)) +
    ylab(NULL) +
    xlab(NULL) +
    theme(
      plot.background = element_rect(fill = "gray15", color = NA),
      panel.background = element_rect(fill = "gray15", color = NA),
      panel.spacing = unit(1 / 8, "in", data = NULL),
      legend.position = "none",
      panel.grid = element_line(color = "gray25"),
      panel.grid.major = element_line(linewidth = 0.35),
      panel.grid.minor = element_line(linewidth = 0.1),
      axis.text = element_text(
        color = "gray70", family = font_chart_axes,
        face = "bold", size = 5
      )
    )
}

#' Combine plots
#'
#' Combine static map and static chart for given year to create single animation
#' frame.
#'
#' @param chart_data Data frame for the chart data.
#' @param col_lines Vector (length = 2) of colors for the graph lines.
#' @param font_chart_titles Font name for the chart titles (facet strip text)
#' @param font_chart_axes Font name for axis lables
#' @param basemap Basemap raster.
#' @param fire_pts Fire occurrence points.
#' @param col_fire Color of the fire points.
#' @param font_year Font name for the printed year.
#' @param year Year from which to plot data.
#' @param col_bg Color of the image background.
#' @param height Height of the image in inches.
#' @param width Width of the image in inches.
#' @param file_out The output filename with extension.
#'
combine_plots <- function(chart_data,
                          col_lines,
                          font_chart_titles,
                          font_chart_axes,
                          basemap, fire_pts,
                          col_fire, font_year,
                          font_main_title,
                          usgs_logo_file,
                          year, col_bg,
                          height, width,
                          file_out) {
  # Build output path
  out_path <- sprintf("3_visualize/out/anim_frames/%s", file_out)

  # Plot constituent plots
  plot_top <- build_map(
    basemap = basemap, fire_pts = fire_pts, year = year,
    col_fire = col_fire, font_year
  )
  plot_bottom <- build_graph(
    chart_data = chart_data,
    year = year,
    font_chart_titles = font_chart_titles,
    font_chart_axes = font_chart_axes,
    col_lines = col_lines
  )

  # Combine plots
  plot_grid(plot_top, plot_bottom, ggdraw(), ncol = 1, rel_heights = c(1.8, 1, 0.26)) +
    
    # Add chart title
    draw_label(
      label = chart_data$name[1], x = 0.07, y = 0.41, hjust = 0,
      size = 5.5, color = "gray70", fontfamily = font_chart_titles, fontface = "bold"
    ) +

    # Add year
    draw_label(
      label = floor(year), x = 0.07, y = 0.47, hjust = 0,
      size = 18, color = "gray65", fontfamily = font_year, fontface = "bold"
    ) +
    
    # Add name and data source
    draw_label(
      label = "Anthony Martinez, USGS\nData: https://doi.org/10.2737/WO-GTR-99",
      x = 0.97, y = 0.04,
      size = 5, color = "gray60", fontfamily = font_chart_titles, hjust = 1
    ) +
    
    # Add USGS logo
    draw_image(usgs_logo_file, x = 0.03, y = -0.45, width = 0.18)

  # Export data
  ggsave(
    filename = out_path,
    bg = col_bg, height = height, width = width, units = "in", dpi = 300
  )

  return(out_path)
}

#' Animate frames into a gif
#'
#' Using input frames, animate into a gif, interpolating as necessary.
#'
#' @param in_frames Filepaths to frames to animate.
#' @param out_file File path, name, and extension of animated gif.
#' @param inter_frames Number of interpolated frames between frames.
#' @param reduce Reduce file size by using only 256 colors. Must have gifsicle
#'   installed (can be installed with NodeJs at
#'   https://www.npmjs.com/package/gifsicle).
#' @param frame_delay_cs Delay after each frame in 1/100 seconds.
#' @param frame_rate Frames per second.
#' @param output_video file also be written as mp4? Requires FFMPEG to be installed
#'
animate_plots <- function(in_frames, out_file, labels, inter_frames, reduce = TRUE,
                          frame_delay_cs, frame_rate, fade_col,output_video = FALSE) {

  img <- image_draw(image_read(in_frames))
  
  out <- image_resize(img, "65x65%") %>%
    {image_join(
      .,
      image_blank(color = fade_col, width = image_info(.[1])$width, height = image_info(.[1])$height),
      image_blank(color = fade_col, width = image_info(.[1])$width, height = image_info(.[1])$height),
      tail(., 1)
    )} %>%
    image_morph(frames = inter_frames) %>%
    head(-1)
  
  out <- out  %>%
    image_animate(
      delay = frame_delay_cs,
      optimize = TRUE,
      fps = frame_rate
    ) %>%
    image_write(out_file)
  
  if (reduce == TRUE) {
    optimize_gif(out_file, frame_delay_cs)
  }
  
  if (output_video == TRUE) {
    out_video_file <- str_replace(out_file, ".gif", ".mp4")
    video_conversion_command <- sprintf(
      'ffmpeg -i %s -movflags faststart -y -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" %s',
      out_file,
      out_video_file
    )
    system(video_conversion_command)
    
    return(out_file)
  }
}

optimize_gif <- function(out_file, frame_delay_cs) {

  # simplify the gif with gifsicle - cuts size by about 2/3
  gifsicle_command <- sprintf(
    "gifsicle -b -O3 -d %s --colors 256 %s",
    frame_delay_cs, out_file
  )
  system(gifsicle_command)

  return(out_file)
  
}
