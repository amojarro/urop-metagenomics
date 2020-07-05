# UROP Metagenomics Pipeline
 
## About

```
Angel Mojarro & Alexis D Cho
```

### Motivation



### Methods
CarrierSeq implements ```bwa-mem``` (Li, 2013) to first map all reads to the genomic carrier then extracts unmapped reads by using ```samtools``` (Li et al., 2009) and ```seqtk``` (Li, 2012). Thereafter, the user can define a quality score threshold and CarrierSeq proceeds to discard low-complexity reads with ```fqtrim``` (Pertea, 2015). This set of unmapped and filtered reads are labeled “reads of interest” and should theoretically comprise target reads and likely contamination. However, reads of interest may also include “high-quality noise reads” (HQNRs), defined as reads that satisfy quality score and complexity filters yet do not match to any database and disproportionately originate from specific channels. By treating reads as a Poisson arrival process, CarrierSeq models the expected reads of interest channel distribution and rejects data from channels exceeding a reads/channels threshold (xcrit). Reads of interest are then sorted into ```08_target_reads``` (reads/channel ≤ xcrit) or ```07_hqnrs``` (reads/channel > xcrit).

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
