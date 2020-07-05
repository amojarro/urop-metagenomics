# UROP Metagenomics Pipeline
 
## About
``` bash
Angel Mojarro & Alexis D Cho
```
### Motivation

This script was written to automate the analysis of metagenomic data and is currently a work in progress. 

### Methods

1. Map short-reads to a reference genome(s) (if applicable) with bwa
2. Split mapped and unmapped reads with samtools
3. Assemble contigs using the unmapped short-reads with megahit
4. Test assembly quality by mapping clean short-reads to contigs using bwa
5. Bin megahit contigs with MaxBin2, MetaBAT2, and Concoct
6. Check bin completeness and contamination with CheckM
7. Refine bins and output Step 5 to Step 9 from the [![metaWRAP guide](https://github.com/bxlab/metaWRAP/blob/master/Usage_tutorial.md)] (work in progress)


8. Classify clean short-reads, unmapped short-reads, and contigs
9. Predict contig genes with prokka and prodigal

## Requirements
Install and setup MiniConda 3 - https://docs.conda.io/en/latest/miniconda.html
``` bash
chmod +x chmod +x Miniconda3-latest-MacOSX-x86_64.sh
conda config --add channels bioconda
conda config --add channels conda-forge
conda create -n urop-meta samtools bwa seqtk prokka prodigal megahit seqtk kraken2 maxbin2 openjdk metabat2 checkm-genome concoct
```

Set CheckM database - https://github.com/Ecogenomics/CheckM/wiki
``` bash
checkm data setRoot <checkm_data_dir>
```

## Using UROP Metagenomics Pipeline
Define the following paths and parameters.
``` bash
clean_short_reads="" # These are your cleaned short reads e.g., quality filtered and adapters have been removed
reference_genome="" # Human contamination, etc.
megahit_preset="" # meta-large or meta-sensitive
threads="" # Number of CPU cores
output_folder="" # Where should this write to?
sample_id="" # Define your sample ID
kraken_db1="" # Kraken2 --standard
kraken_db2="" # Plants, fugi, and protozoa?
```
Runing the pipeline.
``` bash
conda activate urop-meta
chmod +x urop-meta.sh
./urop-meta.sh
```
