library(sf)
library(dplyr)
library(lwgeom)

# using planar geometry
sf::sf_use_s2(FALSE)

# load data
states1920 <- geobr::read_state(year = 1920, simplified = F)
plot(states1920)

# test summarise with original data
states1920$br <- 1

states1920 |>
  group_by(br) |>
  summarise() |>
  plot(col='gray90')


# using make_valid and buffer
states1920 |>
  sf::st_make_valid() |>
  sf::st_buffer(dist = 0) |>
  group_by(br) |>
  summarise() |>
  plot(col='gray90')


# using st_snap_to_grid
states1920 |>
  sf::st_make_valid() |>
  st_transform(crs = 32722) |>

  lwgeom::st_snap_to_grid(size = 0.01) |>
  group_by(br) |>
  summarise() |>
  plot(col='gray90')


t <- dissolve_polygons(mysf=states1920, group_column='name_state')
plot(t,col='gray90')


# using sfheaders
states1920 |>
  sf::st_make_valid() |>
  group_by(br) |>
  summarise() |>
  sfheaders::sf_remove_holes() |>
  plot(col='gray90')

# using nngeo
states1920 |>
  sf::st_make_valid() |>
  group_by(br) |>
  summarise() |>
  nngeo::st_remove_holes() |>
  plot(col='gray90')

# using smoothr. This is the slowest solution
area_thresh <- units::set_units(800, km^2)

states1920 |>
  sf::st_make_valid() |>
  group_by(br) |>
  summarise() |>
  smoothr::fill_holes(threshold = area_thresh) |>
  plot(col = "gray90")




# using rmapshaper. It works by simplifying geometries, which I would consider
# and unwanted side effect in this case

states1920 |>
  sf::st_make_valid() |>
  group_by(br) |>
  summarise() |>
  rmapshaper::ms_simplify() |>
  plot(col='gray90')






# mother ship
dissolve_polygons <- function(temp_sf, f){


  # c) long but complete dissolve function
  dissolvefun <- function(grp){

    # c.1) subset region
    temp_region <- subset(temp_sf, name_state== grp )
    #temp_region <- fgeos(temp_region)
    temp_region <- f(temp_region)
    return(temp_region)
  }


  # Apply sub-function
  groups_sf <- pbapply::pblapply(X = unique(temp_sf$name_state), FUN = dissolvefun )

  # rbind results
  groups_sf <- do.call('rbind', groups_sf)
  return(groups_sf)
}

##### sfheaders


sfh2 <- dissolve_polygons(temp_sf = df, f = sfheaders::sf_remove_holes)
sfh2$br <- 1
sfh2 |> group_by(br) |> summarise() |> plot()


##### rgeos
library(rgeos)

fgeos <- function(temp_region){

wm <- as(temp_region, "Spatial")
cs <- gUnaryUnion(wm, id=as.character(temp_region$nome))
cs_sf <- st_as_sf(cs)
cs_sf$nome <- row.names(cs)
return(cs_sf)
}
cs_sf$br <- 1
cs_sf |> group_by(br) |> summarise() |> plot()




fgeos2 <- dissolve_polygons(temp_sf = df, f = fgeos)
fgeos2$br <- 1
fgeos2 |> group_by(br) |> summarise() |> plot()


##### outer ring

ering <- function(temp_region){

  temp_region <- fix_topoly(temp_region)
  with_holes <- temp_region |>st_union()

  if (class(with_holes)[1] == 'sfc_MULTIPOLYGON'){
  ext_ring <- st_polygon(with_holes[[1]][[1]]) |> st_sfc(crs = st_crs(temp_region))
  }

  if (class(with_holes)[1] == 'sfc_POLYGON'){
    ext_ring <- st_polygon(with_holes[[1]][1]) |> st_sfc(crs = st_crs(temp_region))
  }
  ext_ring <- sf::st_sf(ext_ring)
  ext_ring |> dplyr::rename(geometry = ext_ring)
  ext_ring$nome <- temp_region$nome
  return(ext_ring)
}

ering2 <- dissolve_polygons(temp_sf = df, f = ering)
ering2$br <- 1
ering2 |> group_by(br) |> summarise() |> plot()






# pedro
pedrof <- function(temp_region){

  # c.2) create attribute with the number of points each polygon has
  points_in_each_polygon = sapply(1:dim(temp_region)[1], function(i)
    length(sf::st_coordinates(temp_region$geom[i])))

  temp_region$points_in_each_polygon <- points_in_each_polygon
  mypols <- subset(temp_region, points_in_each_polygon > 0)

  # d) convert to sp
  sf_regiona <- mypols |> as("Spatial")
  sf_regiona <- rgeos::gBuffer(sf_regiona, byid=TRUE, width=0) # correct eventual topology issues

  # c) dissolve borders to create country file
  result <- maptools::unionSpatialPolygons(sf_regiona, rep(TRUE, nrow(sf_regiona@data))) # dissolve


  # d) get rid of holes
  outerRings = Filter(function(f){f@ringDir==1},result@polygons[[1]]@Polygons)
  outerBounds = sp::SpatialPolygons(list(sp::Polygons(outerRings,ID=1)))

  # e) convert back to sf data
  outerBounds <- st_as_sf(outerBounds)
  outerBounds <- st_set_crs(outerBounds, st_crs(temp_region))
  st_crs(outerBounds) <- st_crs(temp_region)

  # retrieve code_region info and reorder columns
  outerBounds$nome <- temp_region$nome


    return(outerBounds)
}

pedrof2 <- dissolve_polygons(temp_sf = df, f = pedrof)
pedrof2$br <- 1
pedrof2 |> group_by(br) |> summarise() |> plot()




##### lw
library(lwgeom)

lw <- function(temp_region){

  temp_region2 <- temp_region %>%
    st_make_valid() %>%
    st_snap_to_grid(size = 0.00000001) %>%
    st_make_valid() %>%
    group_by(br) %>%
    summarise() %>%
    ungroup()

  temp_region2$nome <- temp_region$nome

  return(temp_region)
}

lw2 <- dissolve_polygons(temp_sf = df, f = lw)
lw2$br <- 1
lw2 |> group_by(br) |> summarise() |> plot()



##### poly
library(polyclip)

pl <- function(temp_region){

  # https://github.com/defuneste/utile_comme_du_pq/blob/master/src/functions.R
  testing_polyclip_polyclip <- function(geom) {
    # convert to polyclip format
    sfheader_obj <- sfheaders::sf_to_df(geom)
    sfheader_obj <- sfheader_obj[1:nrow(sfheader_obj) - 1, ]
    list_of_x_y <- list(x = sfheader_obj$x, y = sfheader_obj$y)
    # use of a part of spatstat :
    # https://github.com/spatstat/spatstat.geom/blob/d90441de5ce18aeab1767d11d4da3e3914e49bc7/R/window.R#L230-L240
    xrange <- range(list_of_x_y$x)
    yrange <- range(list_of_x_y$y)
    xrplus <- mean(xrange) + c(-1, 1) * diff(xrange)
    yrplus <- mean(yrange) + c(-1, 1) * diff(yrange)
    # this tricks ..
    bignum <- (.Machine$integer.max ^ 2) / 2
    epsclip <- max(diff(xrange), diff(yrange)) / bignum
    # getting poly B in right order and polyclip format
    poly_b <- list(list(x = xrplus[c(1, 2, 2, 1)], y = yrplus[c(2, 2, 1, 1)]))

    bb <- polyclip::polyclip(
      list_of_x_y,
      poly_b,
      "intersection",
      fillA = "nonzero",
      fillB = "nonzero",
      eps = epsclip
    )
    # back to sf
    list_of_sf <- lapply(bb, as.data.frame) |>
      lapply(sfheaders::sf_polygon)
    do.call(rbind, list_of_sf)
  }

  temp_region2 <- testing_polyclip_polyclip(temp_region)

  temp_region2$nome <- temp_region$nome

  return(temp_region)
}

pl2 <- dissolve_polygons(temp_sf = df, f = pl)
pl2$br <- 1
pl2 |> group_by(br) |> summarise() |> plot()






##### sample point
library(concaveman)

sss <- function(temp_region){ # temp_region = df[4,]

  temp_region2 <- fix_topoly(temp_region)
  # temp_region2 <- st_multipolygon(temp_region$geometry[[1]])
  # temp_region2 <- st_cast(temp_region2,"LINESTRING")
  plot(temp_region2)

  poly_points <- st_segmentize(temp_region2, dfMaxLength = 1000) %>%
    st_coordinates() |>
    as.data.frame() |>
    select(X, Y) |>
    st_as_sf(coords = c("X", "Y"))

  poly <- concaveman(poly_points)

  # new_shape <- sf::st_segmentize(x = temp_region2
  #                                ,dfMaxLength =  units::set_units(1000 / 1000, "km")
  #                              )
  # new_shape <- sfheaders::sf_cast(new_shape, "POINT")

  # temp_region2 <- st_union(temp_region2)
  # temp_region2 <- st_cast(temp_region2, "MULTIPOLYGON")
  # temp_region$geometry[[1]] <- temp_region2

  # retrieve code_region info and reorder columns
  poly$nome <- temp_region$nome

  return(poly)
}

sss2 <- dissolve_polygons(temp_sf = sta, f = sss)
sss2$br <- 1
#sss2 <- fix_topoly(sss2)
sss2 |> group_by(br) |> summarise() |> plot()




t <- dissolve_polygons(mysf = states1920, group_column = 'br')
plot(t, col='gray90')
head(t)


