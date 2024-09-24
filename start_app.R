

# libraries
# Appel aux différents packages utilisés dans la Shiny App
library(shiny)            # Pour construire l'application web
library(shinydashboard)   # Pour construire une application sous forme de tableau de bord
library(plotly)           # Permet de faire des plots, notamment le GANTT
library(sf)               # Lecture de données spatiales/géographiques
library(bslib)            # Layout, mise en forme, cards etc.
library(bsicons)          # librairie d'icones en complément de bslib
library(leaflet)          # Permet d'afficher les fonds de carte et de rendre la carte interactive
library(DT)               # Pour lire, traiter, afficher des data tables
library(dplyr)            # Pour travailler avec des data frames
library(shinycssloaders)  # Pour animer des temps de chargement
library(htmltools)        # Affichage des thematiques avec retour a la ligne

# directories
# (Permet de faire fonctionner l'application depuis n'importe quel moniteur contenant le dossier projet)
root_dir = getwd()
data_dir = sprintf("%s/data",root_dir)
src_dir = sprintf("%s/src", root_dir)

# Permet à l'application d'accéder aux fonctions requises pour son bon fonnctionnement
# Attention l'ordre est important car certaines fonctions ont besoin des résultats fournis par d'autres fonctions
source(sprintf("%s/set_axis_values.R", src_dir), echo=FALSE)
source(sprintf("%s/load_data.R", src_dir), echo=FALSE)
source(sprintf("%s/load_geojson.R", src_dir), echo=FALSE)
source(sprintf("%s/load_palette.R", src_dir), echo=FALSE)
source(sprintf("%s/split_vec_string.R", src_dir), echo=FALSE)
source(sprintf("%s/ui.R", src_dir), echo=FALSE)
source(sprintf("%s/server.R", src_dir), echo=FALSE)


# Lancement de l'application
runApp("app.R")

