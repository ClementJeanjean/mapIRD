

## <div align="left"><img src="www/mapIRD_logo.png" height="100" /><br/>An interactive Shiny dashboard to track and visualize agent assignments over time.</div>


by Clément Jeanjean | last update: February 2026

 
  - [Description](#description)
  - [Quick start](#quick-start)
  - [Input](#inputs)
  - [App overview](#app-overview)

## Description
**mapIRD** is a Shiny application built in **R** that allows users to **explore, visualize, and track international assignments** of IRD agents over time on an interactive world map. ([github.com](https://github.com/ClementJeanjean/mapIRD))

This document walks you through:
1. Project overview
2. Setup & prerequisites  
3. Repository structure  
4. Installing and Running the app locally  

## 1. Project Overview

*mapIRD* is a Shiny web application. Shiny apps are R projects that expose interactive UI components and server logic via a web interface. mapIRD is structured as a project that can be launched locally with [R](https://www.r-project.org/) or [RStudio](https://docs.posit.co/ide/user/).

## 2. Setup & prerequisties

Before running *mapIRD*, make sure you have:
1. **R (≥ 4.0)** installed — download from https://cran.r-project.org  
2. **RStudio** (optional but highly recommended) - download from https://posit.co/download/rstudio-desktop/
3. Internet access for package installation

The mapIRD project comes with test data inspired by real data from the intership during which the app was initially developped. Real names and dates have been replaced for confidentiality reasons.

The data is organised like so : 

| Individu |	Pays_fr |	Pays_eng |	Zone_géographique_fr |	Acronyme_unité |	Projection_sud |	Intitulé |	Durée |	Début |	Fin |	Destination |	Partenaires |	Thématique |
|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
| LAST_NAME First_name |	Pays |	Country	 | Zone géographique |	UNIT |	projection |	intitulé de la mission |	XX mois |	jj/mm/yy |	jj/mm/yy |		pays |	partenaire |	"thématique n°1; thématique n°2; ..." |
|...|...|...|...|...|...|...|...|...|...|...|...|...|

### If you want to test mapIRD with your own data :
Data should be stored in a tab separated txt file. 
⚠️ please respect date format : jj/mm/yy
⚠️ You can write multiple thematics, but they must be separated by ";" and the whole must be enclosed by double quotes.


## 3. Repository Structure

Below is the high-level structure of the repository:
```
├── data/
├── src/
├── www/
├── app.R
├── start_app.R
├── mapIRD.Rproj
├── README.md
```

### Root files

- **`app.R`** — The main Shiny application entry point. This file contains the UI definitions and server logic necessary to launch the reactive application. ([github.com](https://github.com/ClementJeanjean/mapIRD))  
- **`start_app.R`** — A convenience script that sources necessary functions and launches `app.R`. ([github.com](https://github.com/ClementJeanjean/mapIRD/start_app.R))  
- **`mapIRD.Rproj`** — RStudio project file, helps with consistent working directory and quick project launch. ([github.com](https://github.com/ClementJeanjean/mapIRD/mapIRD.Rproj))  
- **`README.md`** — Project documentation (this file). ([github.com](https://github.com/ClementJeanjean/mapIRD/README.md))

### Folders

- **`data/`** — Contains static datasets used by the app (test data, world map coordinates, ...). The app reads from this folder by default; users can replace or extend these datasets as needed. ([github.com](https://github.com/ClementJeanjean/mapIRD/data/))  
- **`src/`** — Contains app functions. ([github.com](https://github.com/ClementJeanjean/mapIRD/data/src)) 
- **`www/`** — Static web assets (CSS, JavaScript, images) served by Shiny; referenced in the UI. ([mjfrigaard.github.io](https://mjfrigaard.github.io/shiny-app-pkgs/shiny.html?utm_source=chatgpt.com))

---


### Shiny App Anatomy (quick)

Shiny apps typically have:

- A **UI section** defining layout and widgets. ([mjfrigaard.github.io](https://mjfrigaard.github.io/shiny-app-pkgs/shiny.html?utm_source=chatgpt.com))  
- A **Server section** containing reactive logic and outputs. ([mjfrigaard.github.io](https://mjfrigaard.github.io/shiny-app-pkgs/shiny.html?utm_source=chatgpt.com))  
- Data loaded at the top (global scope) or inside server logic.  
- Static assets in `www/` for styling and scripting.

In *mapIRD*, all core app logic lives inside `app.R`. Helper functions or shared routines (if any) are in `src/`.

---


## 4. Installing and Running the app locally 

### 4.1 Clone the repository

```bash
git clone https://github.com/ClementJeanjean/mapIRD.git
cd mapIRD
```

## 4.2 launch the app from RStudio

### With **RStudio** :

```r
# Install packages if not already installed
required_pkgs <- c(
  "shiny",   # core Shiny
  "leaflet", # interactive maps
  "dplyr",   # data manipulation
  "sf"       # spatial data handling
)

installed <- installed.packages()
for (pkg in required_pkgs) {
  if (!pkg %in% installed[, "Package"]) install.packages(pkg)
}
```

Then, launch the app :
1. Open **`mapIRD.Rproj`** in RStudio.  
2. Open **`start_app.R`** or **`app.R`**.  
3. Click **Run App** (top right of the script window).  

RStudio will automatically launch the Shiny app in the Viewer pane or your default browser.

### With **R** :

Make sure your working directory is the repository root, then run:

```r
# You can run the main app directly
shiny::runApp("app.R")

# Or you can also run the app via helper script
source("start_app.R")
```

This will start the Shiny server and open a new browser window with the interactive interface.







## Quick start
A quick-to-run test dataset is available in 'data/' to check if the app suits your needs (see more details in [Input](#input) section).

First, Rstudio must be installed on your machine.

Then, clone the repository:
```commandline
   mkdir mapIRD
   git clone https://github.com/ClementJeanjean/mapIRD.git
   cd mapIRD
```

## :inbox_tray: Input
The input data consists of a table with fictionnal agents and missions.

Your **input** table must have four named columns: 
* **info1**: sample name used to link corresponding FASTQ files
* **info2**: sample name used to link corresponding FASTQ files 
* **info3**: path to FASTQ file
* **info4**: seed to initialize the random number generator

| info1 | info2 | info3 | info4 | 
|-------|-------|-------|-------|
| ...   | ...   | ...   | ...   | 
| ...   | ...   | ...   | ...   | 
| ...   | ...   | ...   | ...   | 

## App overview


