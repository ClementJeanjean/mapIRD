

## <div align="left"><img src="mapIRD_logo.png" height="100" /><br/>An interactive Shiny dashboard to track and visualize agent assignments over time.</div>


by Clément Jeanjean | last update: February 2026

 
  - [Description](#description)
  - [Quick start](#quick-start)
  - [Input](#inputs)
  - [App overview](#app-overview)

## Description
mapIRD is a R Shiny App to visualize the international assignments of IRD agents over time. The app features an interactive world map to help visualizing where IRD agents are operating. By clicking on a given country, the user can quickly get an overview of ongoing missions (programs, number of agents, scientific themes, ...). The app also features a dynamic schedule of ongoing and future operations for each agent.

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


