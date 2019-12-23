library(hexSticker) # https://github.com/GuangchuangYu/hexSticker
library(ggplot2)
library(sf)
library(geobr)

library(extrafont)
font_import()
loadfonts(device = "win")


# Download shape files
  system.time( meso <- read_meso_region(code_meso="all", year=2010) )
  system.time( uf <- read_state(code_state="all", year=2010) )

# add special text font
  library(sysfonts)
  font_add_google(name = "Roboto", family = "Roboto")
  # font_add_google(name = "HelveticaR", family = "Linotype")



### Yellow and blue logo ---------------

plot_y <-
  ggplot() +
  geom_sf(data = meso, fill=NA, size=.15, color="#272D67") +
  geom_sf(data = uf, fill=NA, size=.4, color="#2E3946") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="black",
           size = 5, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)


# .png
sticker(plot_y, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#FEB845", h_color="#FE9F45", # hexagon
        filename="./man/figures/geobr_logo_y2.png", dpi=400)  # output name and resolution


beepr::beep()




### Blue and Yellowd logo ---------------

# .png
plot_b <-
  ggplot() +
  geom_sf(data = meso, fill=NA, size=.15, color="#FEB845") +
  geom_sf(data = uf, fill=NA, size=.4, color="#FEBF57") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="#FEB845",
           size = 6, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)


sticker(plot_b, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#2D3E50", h_color="#1f2b38", h_size=1.5, # hexagon
        filename="./man/figures/geobr_logo_b.png", dpi=400)  # output name and resolution



# .svg

plot_b <-
  ggplot() +
#  geom_sf(data = meso, fill=NA, size=.15, color="#FEB845") +
  geom_sf(data = uf, fill=NA, size=.4, color="#FEBF57") +
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="#FEB845",
           size = 6, family = "Roboto", fontface="bold", angle = 0) # (.png  size = 25)(.svg  size = 6)

sticker(plot_b, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#2D3E50", h_color="#1f2b38", h_size=1.5, # hexagon
        filename="./man/figures/geobr_logo_b3.svg")  # output name and resolution


beepr::beep()



