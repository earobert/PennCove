
# MODIS data

#====
# Examples of each step
#====
# Upload data or files with web scraping in r
# https://blog.rstudio.org/2014/11/24/rvest-easy-web-scraping-with-r/
install.packages("rvest")
library(rvest)
lego_movie <- read_html("http://www.imdb.com/title/tt1490017/")

lego_movie %>% 
  html_node("strong span") %>%
  html_text() %>%
  as.numeric()
#> [1] 7.9

help("html_node")

#====
# Open .nc files 
# http://gis.stackexchange.com/questions/120900/plotting-netcdf-file-using-lat-and-lon-contained-in-variables

# First, estimate the extent.
# We start with the lat and long, then project it to the Lambert Conformal projection
library(raster)
inputfile <- "pr_averaged_Med_CORDEX_ATM.1980-2008.nc"

# Grab the lat and lon from the data
lat <- raster(inputfile, varname="xlat")
lon <- raster(inputfile, varname="xlon")

# Convert to points and match the lat and lons
plat <- rasterToPoints(lat)
plon <- rasterToPoints(lon)
lonlat <- cbind(plon[,3], plat[,3])

# Specify the lonlat as spatial points with projection as long/lat
lonlat <- SpatialPoints(lonlat, proj4string = CRS("+proj=longlat +datum=WGS84"))

# Need the rgdal package to project it to the original coordinate system
library("rgdal")

# My best guess at the proj4 string from the information given
mycrs <- CRS("+proj=lcc +lat_1=35 +lat_2=51 +lat_0=39 +lon_0=14 +k=0.684241 +units=m +datum=WGS84 +no_defs")
plonlat <- spTransform(lonlat, CRSobj = mycrs)
# Take a look
plonlat
extent(plonlat)

# Yay! Now we can properly set the coordinate information for the raster
pr <- raster(inputfile, varname="pr")
# Fix the projection and extent
projection(pr) <- mycrs
extent(pr) <- extent(plonlat)
# Take a look
pr
plot(pr)

# Project to long lat grid
r <- projectRaster(pr, crs=CRS("+proj=longlat +datum=WGS84"))
# Take a look
r
plot(r)
# Add contours
contour(r, add=TRUE)

# Add country lines
library("maps")
map(add=TRUE, col="blue")
