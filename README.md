# UROP Metagenomics Pipeline
 
## About
``` bash
Angel Mojarro (mojarro @ mit.edu) & Alexis D Cho (adcho @ mit.edu)
```
### Motivation

This script was written to automate the analysis of metagenomic data and is currently a work in progress. 

### Methods

1. Map short-reads to a reference genome(s) (if applicable) with [BWA](https://github.com/lh3/bwa).
2. Split mapped and unmapped reads with [Samtools](https://github.com/samtools/samtools).
3. Assemble contigs using the unmapped short-reads with [MEGAHIT]https://github.com/voutcn/megahit.
4. Test assembly quality by mapping clean short-reads to contigs using [BWA](https://github.com/lh3/bwa).
5. Bin megahit contigs with [MaxBin2](https://sourceforge.net/projects/maxbin2/), [MetaBAT2](https://bitbucket.org/berkeleylab/metabat/src/master/), and [Concoct](https://github.com/BinPro/CONCOCT).
6. Check bin completeness and contamination with [CheckM](https://github.com/Ecogenomics/CheckM).
7. Refine bins and output Step 5 to Step 9 from the [MetaWRAP guide](https://github.com/bxlab/metaWRAP/blob/master/Usage_tutorial.md) (work in progress).
8. Classify clean short-reads, unmapped short-reads, and contigs with [kraken2](https://github.com/DerrickWood/kraken2). Bins are classified by [MetaWRAP](https://github.com/bxlab/metaWRAP).
9. Predict contig genes with [Prokka](https://github.com/tseemann/prokka) and [Prodigal](https://github.com/hyattpd/Prodigal).

## Requirements
Note: This script was written on a Linux machine with 8 cores and 64 GB of RAM.

Install and setup MiniConda 3 - https://docs.conda.io/en/latest/miniconda.html
``` bash
chmod +x chmod +x Miniconda3-latest-MacOSX-x86_64.sh
conda config --add channels bioconda
conda config --add channels conda-forge
conda create -n urop-meta samtools bwa prokka prodigal megahit kraken2 maxbin2 openjdk metabat2 checkm-genome concoct
```

Set CheckM database - https://github.com/Ecogenomics/CheckM/wiki
``` bash
checkm data setRoot <checkm_data_dir>
```

Download Kraken2 databases - https://github.com/DerrickWood/kraken2/wiki/Manual#standard-kraken-2-database

Standard dabatase (db1):
``` bash
kraken2-build --standard --threads N --db $path/to/db1
```

Custom database (db2):
``` bash
kraken2-build --threads N --download-taxonomy --db $path/to/db2
kraken2-build --threads N --download-library plants --db $path/to/db2
kraken2-build --threads N --download-library fungi --db $path/to/db2
kraken2-build --threads N --download-library protozoa --db $path/to/db2
kraken2-build --threads N --build --db $path/to/db2
```

## Using UROP Metagenomics Pipeline
Define the following paths and parameters in urop-meta.sh:
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
Runing the pipeline:
``` bash
conda activate urop-meta
chmod +x urop-meta.sh
./urop-meta.sh
```
Results:
``` bash
work in progress!
```
