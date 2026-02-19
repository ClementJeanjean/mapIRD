# Snakemake workflow: <img src="prepkmer_logo.png" align="middle" height="200" /></a>

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](http://www.gnu.org/licenses/gpl.html)       

**Table of Contents**
 
  - [Description](#description)
  - [Quick start](#quick-start)
  - [Input](#inputs)
  - [Output](#outputs)
  - [Parameters](#parameters)
  - [Workflow overview](#workflow-overview)
  - [K-mer database subsampling](#k-mer-database-sub-sampling)
  - [Kmer intersection graph and mapping](#kmer-intersection-graph-and-mapping)

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

## :gear: Parameters

## :mag_right: Workflow overview

### 1) FastQC on raw data
A preliminary quality check is performed on Fastq files with FastQC. HTML reports are generated for each sequence.

### 2) FastP 
FastP trimming is performed on raw sequences with a custom set of Illumina TruSeq adapters.

### 3) FastQC on FastP
A second FastQC quality check is performed on trimmed fastq sequences. Adapter content that could have been left in raw sequences should now be gone.

### 4) Kraken2
Kraken2 is a tool used to remove contaminant genome (organelles, human, bacterial etc.) from the sequences. The default Kraken2 database is completed with a custom set of organelles sequences. Mapped and non-mapped sequences are separated in directories /cleaned_fastq (non-mapped) and /kraken_cleaning (mapped, contaminant fragments). Kraken2 contaminant classification report files are generated for each sequences.

### 5) Krona
Krona interactive plots allow a better visualization of the classification reports provided by Kraken2.

### 6) Construction of FastQ table for Kmercity 
In this final step, the output tab file is generated. New paths are created, leading to cleaned data. Subsampling numbers of reads are calculated from ploidy and user parameters.
