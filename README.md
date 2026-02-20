

## <div align="left"><img src="www/mapIRD_logo.png" height="100" /><br/>An interactive Shiny dashboard to track and visualize agent assignments over time.</div>


by Clément Jeanjean | last update: February 2026

## Description
**mapIRD** is a Shiny application built in **R** that allows users to **explore, visualize, and track international assignments** of IRD agents over time on an interactive world map. ([github.com](https://github.com/ClementJeanjean/mapIRD))

This document walks you through:
- [1. Project overview](https://github.com/ClementJeanjean/mapIRD/edit/main/README.md#1-project-overview)
- [2. Setup & prerequisites](https://github.com/ClementJeanjean/mapIRD/edit/main/README.md#2-setup--prerequisites)
- [3. Repository structure](https://github.com/ClementJeanjean/mapIRD/edit/main/README.md#3-repository-structure)
- [4. Installing and Running the app locally](https://github.com/ClementJeanjean/mapIRD/edit/main/README.md#4-installing-and-running-the-app-locally)
- [5. Troubleshooting](https://github.com/ClementJeanjean/mapIRD/edit/main/README.md#-5-troubleshooting)

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


### Shiny App Anatomy

Shiny apps typically have:

- A **UI section** defining layout and widgets. ([mjfrigaard.github.io](https://mjfrigaard.github.io/shiny-app-pkgs/shiny.html?utm_source=chatgpt.com))  
- A **Server section** containing reactive logic and outputs. ([mjfrigaard.github.io](https://mjfrigaard.github.io/shiny-app-pkgs/shiny.html?utm_source=chatgpt.com))  
- Data are tipically loaded at the top (global scope) or inside (local scope) the server logic.  
- Static assets are stored in `www/` to make them accessible from a temporary server for styling the actual app (logos, images).

In *mapIRD*, all core app logic lives inside `app.R`. Helper functions or shared routines (if any) are in `src/`.

---


## 4. Installing and Running the app locally 

### 4.1 Clone the repository

```bash
git clone https://github.com/ClementJeanjean/mapIRD.git
cd mapIRD
```

## 4.2 launch the app from RStudio

In **RStudio**, from mapIRD project workspace, run :

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


---

## 📌 5. Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|------|
| App fails to start | Missing package | Install missing packages via `install.packages()` |
| Map does not render | `leaflet` or `sf` issues | Ensure `leaflet` and `sf` are installed and working |
| Data not showing | Missing data file or incorrect path or incorrect data syntax | Check `data/` folder for required files and check syntax |

---



