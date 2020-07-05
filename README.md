# UROP Metagenomics Pipeline
 
## About
``` bash
Angel Mojarro & Alexis D Cho
```
### Motivation

### Methods

## Requirements
Install and setup MiniConda 3 - https://docs.conda.io/en/latest/miniconda.html
``` bash
chmod +x chmod +x Miniconda3-latest-MacOSX-x86_64.sh
conda config --add channels bioconda
conda config --add channels conda-forge
conda create -n urop-meta samtools bwa seqtk prokka prodigal megahit seqtk kraken2 maxbin2 openjdk metabat2 checkm-genome concoct
conda activate urop-meta
```

## Using UROP Metagenomics Pipeline
Define the following paths and parameters.
``` bash
clean_short_reads="" # These are your cleaned short reads e.g., quality filtered and adapters have been removed
reference_genome="" # Human contamination, etc.
megahit_preset="meta-large" # meta-large meta-sensitive
threads="" # Number of CPU cores
output_folder="" # Where should this write to?
sample_id="" # Define your sample ID
kraken_db1="" # Kraken2 --standard
kraken_db2="" # Plants, fugi, and protozoa?
```
Runing the pipeline.
``` bash
chmod +x urop-meta.sh
```
