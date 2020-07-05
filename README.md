# UROP Metagenomics Pipeline
 
## About

```
Angel Mojarro & Alexis D Cho
```

### Motivation



### Methods


## Requirements
 
Install and setup MiniConda 3 - https://docs.conda.io/en/latest/miniconda.html
1. ```chmod +x chmod +x Miniconda3-latest-MacOSX-x86_64.sh```

2. ```conda config --add channels bioconda```

3. ```conda config --add channels conda-forge```

4. ```conda create -n urop-meta samtools bwa seqtk prokka prodigal megahit seqtk kraken2 maxbin2 openjdk metabat2 checkm-genome concoct ```

5. ```conda activate urop-meta```

## Using urop-meta.sh

Note: You may first need to make the script executable with:

1.```chmod +x urop-meta.sh```
