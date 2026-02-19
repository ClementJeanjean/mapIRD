# Shiny app: </a><img src="mapIRD_logo.png" align="middle" height="100" /></a>


[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](http://www.gnu.org/licenses/gpl.html)       

**Table of Contents**
 
  - [Description](#description)
  - [Quick start](#quick-start)
  - [Input](#inputs)
  - [Output](#outputs)
  - [App overview](#app-overview)

## Description
PrepKmer is a snakemake workflow to prepare fastq sequences for K-mer diversity analysis. PrepKmer was designed to facilitate preliminary data cleaning required by the snakemake workflow Kmercity (developped by SEG team, CIRAD) 

## Quick start
A quick-to-run test dataset is available in 'data/' to facilitate installation (see more details in [Input](#input) section).

First, [snakemake](https://github.com/snakemake/snakemake) must be installed on your machine.

Then, clone the repository:
```commandline
   mkdir prepkmer
   git clone https://github.com/ClementJeanjean/prepkmer.git
   cd prepkmer
```

## :inbox_tray: Input
The input data consists of a table informing compressed single- or paired-end sequencing files (FASTQ.GZ).

The **input** FASTQ table must have four named columns: 
* **Sample**: sample name used to link corresponding FASTQ files
* **Ploidy**: sample name used to link corresponding FASTQ files 
* **FastQ**: path to FASTQ file
* **Seed**: seed to initialize the random number generator

| Sample | FastQ                     | ploidy | Seed | 
|--------|---------------------------|--------|------|
| IND1   | path/to/IND1_R1.fastq.gz  | ...    | 123  | 
| IND1   | path/to/IND1_R2.fastq.gz  | ...    | 456  | 
| IND2   | path/to/IND2_R1.fastq.gz  | ...    | 123  | 
| IND2   | path/to/IND2_R2.fastq.gz  | ...    | 456  | 

## App overview


## :outbox_tray: Output

The **output** FASTQ table must have five named columns: 
* **Sample**: sample name used to link corresponding FASTQ files
* **Ploidy**: sample name used to link corresponding FASTQ files 
* **FastQ**: path to FASTQ file
* **NbReads**: column created by the program, informing the number of reads to be randomly sampled using [seqtk](https://github.com/lh3/seqtk)
* **Seed**: seed to initialize the random number generator

| Sample | FastQ                     | ploidy | NbReads | Seed | 
|--------|---------------------------|--------|---------|------|
| IND1   | path/to/IND1_R1.fastq.gz  | ...    | ...     | 123  | 
| IND1   | path/to/IND1_R2.fastq.gz  | ...    | ...     | 456  | 
| IND2   | path/to/IND2_R1.fastq.gz  | ...    | ...     | 123  | 
| IND2   | path/to/IND2_R2.fastq.gz  | ...    | ...     | 456  | 

