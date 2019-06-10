library(hexSticker) # https://github.com/GuangchuangYu/hexSticker
library(ggplot2)
library(sf)
library(geobr)

library(extrafont)
font_import()
loadfonts(device = "win")


# devtools::install_github("ipeaGIT/geobr")


# Download shape files
  system.time( meso <- read_meso_region(cod_meso="all", year=2010) )
  system.time( uf <- read_state(cod_uf="all", year=2010) )
  
# add special text font
  library(sysfonts)
  font_add_google(name = "Roboto", family = "Roboto")
  font_add_google(name = "HelveticaR", family = "Linotype")
  
  

    
### Yellow and blue logo ---------------

# # plot DIAGONAL
# 
# plot <- 
#   ggplot() + 
#   geom_sf(data = meso, fill=NA, size=.15, color="#272D67") + 
#   geom_sf(data = uf, fill=NA, size=.4, color="#2E3946") + 
#   theme_void() +
#   theme(panel.grid.major=element_line(colour="transparent")) +
#   #  theme(legend.position = "none") +
#   annotate("text", x = -64, y = -20, label= "geobr",
#            size = 25, angle = 300) # family = "Roboto", fontface="bold", 
# 
# 
# sticker(plot, package="",
#         s_x=1.1, s_y=.9, s_width=2, s_height=2, # ggplot image size and position
#         h_fill="#FEB845", h_color="#FE9F45", h_size=2, # hexagon
#         filename="geobr_logo.png", dpi=400)  # output name and resolution
# 
# beepr::beep()



# plot horizontal

plot <- 
  ggplot() + 
  geom_sf(data = meso, fill=NA, size=.15, color="#272D67") + 
  geom_sf(data = uf, fill=NA, size=.4, color="#2E3946") + 
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="black",
           size = 25, family = "Roboto", fontface="bold", angle = 0) # 


sticker(plot, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#FEB845", h_color="#FE9F45", h_size=1.5, # hexagon
        filename="geobr_logo_y.png", dpi=400)  # output name and resolution

beepr::beep()




### Blue and Yellowd logo ---------------


# plot horizontal

plot <- 
  ggplot() + 
  geom_sf(data = meso, fill=NA, size=.15, color="#FEB845") + 
  geom_sf(data = uf, fill=NA, size=.4, color="#FEBF57") + 
  theme_void() +
  theme(panel.grid.major=element_line(colour="transparent")) +
  #  theme(legend.position = "none") +
  annotate("text", x = -67.7, y = -20, label= "geobr", color="#FEB845",
           size = 25, family = "helvetica", fontface="bold", angle = 0) # 


sticker(plot, package="",
        s_x=1.12, s_y=.9, s_width=1.8, s_height=1.8, # ggplot image size and position
        h_fill="#2D3E50", h_color="#1f2b38", h_size=1.5, # hexagon
        filename="geobr_logo_b_helvetica.png", dpi=400)  # output name and resolution

beepr::beep()

