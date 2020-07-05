# UROP Metagenomics Pipeline
 
## About

```
Angel Mojarro & Alexis D Cho
```

### Motivation



### Methods


## Requirements

MiniConda 3
```chmod +x chmod +x Miniconda3-latest-MacOSX-x86_64.sh```
```conda config --add channels bioconda```
```conda config --add channels conda-forge```
```conda create -n urop-meta samtools bwa seqtk prokka prodigal megahit seqtk kraken2 maxbin2 openjdk metabat2 checkm-genome concoct ```
```conda activate urop-meta```

## Using urop-meta.sh

Note: You may first need to make the script executable with:

```chmod +x urop-meta.sh```
