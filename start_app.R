# libraries
# Calling packages used in the Shiny App
library(shiny)            # Builds the web app
library(shinydashboard)   # Builds the web app in dashboard format
library(plotly)           # Plots, GANTT
library(sf)               # Reads spatial/geographic data
library(bslib)            # Layout, design formatting, cards etc.
library(bsicons)          # Complementary bslib icons library
library(leaflet)          # Displays maps and make them interactive
library(DT)               # Read, process, display data tables
library(dplyr)            # Working with data frames
library(shinycssloaders)  # Loading animations
library(htmltools)        # Diplay themes with a return to line

# directories
root_dir = getwd()
data_dir = sprintf("%s/data",root_dir)
src_dir = sprintf("%s/src", root_dir)

# Allows the application to access the functions required for its proper operation
# Note that the order is important because some functions need the results provided by other functions
source(sprintf("%s/set_axis_values.R", src_dir), echo=FALSE)
source(sprintf("%s/load_data.R", src_dir), echo=FALSE)
source(sprintf("%s/load_geojson.R", src_dir), echo=FALSE)
source(sprintf("%s/load_palette.R", src_dir), echo=FALSE)
source(sprintf("%s/split_vec_string.R", src_dir), echo=FALSE)
source(sprintf("%s/ui.R", src_dir), echo=FALSE)
source(sprintf("%s/server.R", src_dir), echo=FALSE)


# Launches the app
runApp("app.R")

