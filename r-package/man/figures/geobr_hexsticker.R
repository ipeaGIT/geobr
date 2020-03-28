library(hexSticker) # https://github.com/GuangchuangYu/hexSticker
library(ggplot2)
library(sf)
library(geobr)


# add special text font
library(sysfonts)
font_add_google(name = "Roboto", family = "Roboto")
# font_add_google(name = "HelveticaR", family = "Linotype")

library(extrafont)
font_import()
loadfonts(device = "win")



# Download shape files
  system.time( meso <- read_meso_region(code_meso="all", year=2010) )
  system.time( uf <- read_state(code_state="all", year=2010) )


  # Simplify geometry
  meso_s <- meso %>% sf::st_transform(crs=3857) %>%
    sf::st_simplify( preserveTopology = T, dTolerance = 10000) %>%
    sf::st_transform( crs=4674)


  uf_s <- uf %>% sf::st_transform(crs=3857) %>%
    sf::st_simplify( preserveTopology = T, dTolerance = 10000) %>%
    sf::st_transform( crs=4674)


  plot(meso_s['code_meso'])
  plot(meso['code_meso'])

  plot(uf_s['code_state'])
  plot(uf['code_state'])

  as.numeric(object.size(meso_s))/  as.numeric(  object.size(meso))
  as.numeric(object.size(uf_s))/  as.numeric(  object.size(uf))





### Yellow and blue logo ---------------

### .png
plot_y <-
  ggplot() +
    geom_sf(data = meso_s, fill=NA, size=.155, color="#272D67") +
  geom_sf(data = uf_s, fill=NA, size=.4, color="#2E3946") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="black",
           size = 25, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)



sticker(plot_y, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#FEB845", h_color="#FE9F45", # hexagon
        filename="./man/figures/geobr_logo_y2.png", dpi=400)  # output name and resolution


beepr::beep()



### .svg
plot_y_svg <-
  ggplot() +
  geom_sf(data = meso_s, fill=NA, size=.08, color="#272D67") +
  geom_sf(data = uf_s, fill=NA, size=.35, color="#2E3946") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="black",
           size = 6, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)



sticker(plot_y_svg, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#FEB845", h_color="#FE9F45", # hexagon
        filename="./man/figures/geobr_logo_y2.svg")  # output name and resolution





### Blue and Yellowd logo ---------------

### .png
plot_b <-
  ggplot() +
  geom_sf(data = meso_s, fill=NA, size=.155, color="#FEB845") +
  geom_sf(data = uf_s, fill=NA, size=.4, color="#FEBF57") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="#FEB845",
           size = 25, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)


sticker(plot_b, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#2D3E50", h_color="#1f2b38", h_size=1.5, # hexagon
        filename="./man/figures/geobr_logo_b2.png", dpi=400)  # output name and resolution



### .svg

plot_b_svg <-
  ggplot() +
  geom_sf(data = meso_s, fill=NA, size=.08, color="#FEB845") +
  geom_sf(data = uf_s, fill=NA, size=.35, color="#FEBF57") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="#FEB845",
           size = 6, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)

sticker(plot_b_svg, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#2D3E50", h_color="#1f2b38", h_size=1.5, # hexagon
        filename="./man/figures/geobr_logo_b2.svg")  # output name and resolution


beepr::beep()



### Blue and Yellowd SMALL logo ---------------

# dpi .png107.2

plot_b_small <-
  ggplot() +
  geom_sf(data = meso_s, fill=NA, size=.0001, color="#FEB845") +
  geom_sf(data = uf_s, fill=NA, size=.568, color="#FEBF57") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="#FEB845",
           size = 6.5, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)


sticker2(plot_b_small, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#2D3E50", h_color="#1f2b38", h_size=1.5, # hexagon
        filename="./man/figures/geobr_logo_b_small.png", dpi=120.5)  # output name and resolution






####################################################
# help functions to create small logo
sticker2 <- function (subplot, s_x = 0.8, s_y = 0.75, s_width = 0.4, s_height = 0.5,
                      package, p_x = 1, p_y = 1.4, p_color = "#FFFFFF", p_family = "Aller_Rg",
                      p_size = 8, h_size = 1.2, h_fill = "#1881C2", h_color = "#87B13F",
                      spotlight = FALSE, l_x = 1, l_y = 0.5, l_width = 3, l_height = 3,
                      l_alpha = 0.4, url = "", u_x = 1, u_y = 0.08, u_color = "black",
                      u_family = "Aller_Rg", u_size = 1.5, u_angle = 30, white_around_sticker = FALSE,
                      ..., filename = paste0(package, ".png"), asp = 1, dpi = 300)
{
  hex <- ggplot() + geom_hexagon(size = h_size, fill = h_fill,
                                 color = NA)
  if (inherits(subplot, "character")) {
    d <- data.frame(x = s_x, y = s_y, image = subplot)
    sticker <- hex + geom_image(aes_(x = ~x, y = ~y, image = ~image),
                                d, size = s_width, asp = asp)
  }
  else {
    sticker <- hex + geom_subview(subview = subplot, x = s_x,
                                  y = s_y, width = s_width, height = s_height)
  }
  sticker <- sticker + geom_hexagon(size = h_size, fill = NA,
                                    color = h_color)
  if (spotlight)
    sticker <- sticker + geom_subview(subview = spotlight(l_alpha),
                                      x = l_x, y = l_y, width = l_width, height = l_height)
  sticker <- sticker + geom_pkgname(package, p_x, p_y, p_color,
                                    p_family, p_size, ...)
  sticker <- sticker + geom_url(url, x = u_x, y = u_y, color = u_color,
                                family = u_family, size = u_size, angle = u_angle)
  if (white_around_sticker)
    sticker <- sticker + white_around_hex(size = h_size)
  sticker <- sticker + theme_sticker(size = h_size)
  save_sticker2(filename, sticker, dpi = dpi)
  invisible(sticker)
}


save_sticker2 <- function (filename, sticker = last_plot(), ...)
{
  ggsave(sticker, width = 3.83, height = 4.43, filename = filename,
         bg = "transparent", units = "cm", ...)
}


