#!/bin/bash

# run with Miniconda3
# chmod +x Miniconda3-latest-MacOSX-x86_64.sh <hit enter to give the miniconda script permission to run>
# ./Miniconda3-latest-MacOSX-x86_64.sh <hit enter and follow the on-screen instructions to install>
# conda config --add channels bioconda <hit enter to add the bioconda channel>
# conda config --add channels conda-forge <hit enter to add the conda-forge channel>
# conda create -n urop-meta samtools bwa seqtk prokka prodigal megahit seqtk kraken2 maxbin2 openjdk metabat2 checkm-genome concoct bbmpa
# conda activate urop-meta

# define all variables and parameters
short_reads="" # remove adapters with cutadapt, adapterremoval etc. and other qc first
reference_genome=""
megahit_preset="" # meta-large meta-sensitive
threads=""
output_folder=""
sample_id=""
kraken_db1=""
kraken_db2=""

# Make output directories
echo Creating output directories...
mkdir -p $output_folder/05_clean_reads/
mkdir -p $output_folder/06_bwa_mem_reference_mapping/$sample_id/
mkdir -p $output_folder/07_fasta_ready/
mkdir -p $output_folder/08_megahit_contigs/
mkdir -p $output_folder/09_megahit_contigs_check/
mkdir -p $output_folder/10_binning/$sample_id/$sample_id.maxbin2/
mkdir -p $output_folder/10_binning/$sample_id/$sample_id.metabat2/
mkdir -p $output_folder/10_binning/$sample_id/$sample_id.concoct/bins/
# bin refinement stuff
mkdir -p $output_folder/11_taxonomy/1_unmapped/
mkdir -p $output_folder/11_taxonomy/2_shortreads/
mkdir -p $output_folder/11_taxonomy/3_contigs/
mkdir -p $output_folder/12_genes/prokka/
mkdir -p $output_folder/12_genes/prodigal/


# @adcho add deduplication
# clumpify.sh in=$short_reads out=$output_folder/05_clean_reads/sample_id.deduplicated.fastq.gz dedupe=t subs=2

# @adcho add bracken short read abundance calcs

# mapping
echo Mapping clean short-reads to reference/contamintation genomes...
bwa mem -t $threads $reference_genome $output_folder/05_clean_reads/sample_id.deduplicated.fastq.gz > $output_folder/06_bwa_mem_reference_mapping/$sample_id/$sample_id.refmapping.sam
samtools view -S -f4 $output_folder/06_bwa_mem_reference_mapping/$sample_id/$sample_id.refmapping.sam >  $output_folder/06_bwa_mem_reference_mapping/$sample_id/$sample_id.mapping.unmapped.sam
samtools view -S -F4 $output_folder/06_bwa_mem_reference_mapping/$sample_id/$sample_id.refmapping.sam >  $output_folder/06_bwa_mem_reference_mapping/$sample_id/$sample_id.mapping.mapped.sam
samtools fasta $output_folder/06_bwa_mem_reference_mapping/$sample_id/$sample_id.mapping.unmapped.sam > $output_folder/07_fasta_ready/$sample_id.ready.fasta

# kraken and bracken analysis
kraken2 --db $kraken_db1 $output_folder/07_fasta_ready/$sample_id.ready.fasta --output $output_folder/07_fasta_ready/$sample_id.kraken.db.output --report $output_folder/07_fasta_ready/$sample_id.kraken.db.report --threads $threads
bracken -d $kraken_db1 -i $output_folder/07_fasta_ready/$sample_id.kraken.db.report -o $output_folder/07_fasta_ready/$sample_id.bracken -r 80

# contigs
echo Assembling contigs...
megahit -t $threads --presets $megahit_preset -r $output_folder/07_fasta_ready/$sample_id.ready.fasta -o $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit

# contigs check
echo Mapping clean short-reads to contigs...
cutadapt -j $threads --minimum-length 200 -o $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.filtered.contigs.fasta $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa
bwa index  $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.filtered.contigs.fasta
bwa mem -t $threads $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.filtered.contigs.fasta $output_folder/07_fasta_ready/$sample_id.ready.fasta > $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.sam
samtools view -b $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.sam > $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.bam
samtools sort $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.bam > $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.sorted.bam
rm $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.bam

# @adcho add contig QC
# @adcho pass cleaned contigs to binning
# @adcho look at Metagenome-Atlas config.yaml file for potential parameters

# binning
## maxbin2
echo Binning with MaxBin2...
pileup.sh in=$output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.sam out=$output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.txt
awk '{print $1"\t"$5}' $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.check.txt | grep -v '^#' > $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.abundance.txt
run_MaxBin.pl -thread $threads -contig $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa -out $output_folder/10_binning/$sample_id/$sample_id.maxbin2/$sample_id.maxbin2 -abund $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.abundance.txt
checkm lineage_wf -t $threads -x fasta -f $output_folder/10_binning/$sample_id/$sample_id.maxbin2.checkm/checkm.txt $output_folder/10_binning/$sample_id/$sample_id.maxbin2 $output_folder/10_binning/$sample_id/$sample_id.maxbin2.checkm/

## metabat2
echo Binning with MetaBAT2...
jgi_summarize_bam_contig_depths --outputDepth $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.depth.txt $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.sorted.bam
metabat2 -i $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa -a $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.depth.txt -o $output_folder/10_binning/$sample_id/$sample_id.metabat2/bins
checkm lineage_wf -t $threads -x fa -f $output_folder/10_binning/$sample_id/$sample_id.metabat2.checkm/checkm.txt $output_folder/10_binning/$sample_id/$sample_id.metabat2 $output_folder/10_binning/$sample_id/$sample_id.metabat2.checkm/

## concoct
# lets keep this but maybe remove in future versions
# echo Binning with Concoct...
# samtools index $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.sorted.bam
# cut_up_fasta.py $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa -c 10000 -o 0 --merge_last -b $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.contigs_10K.bed > $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.contigs_10K.fa
# concoct_coverage_table.py $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.contigs_10K.bed $output_folder/09_megahit_contigs_check/$sample_id/$sample_id.$megahit_preset.sorted.bam > $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.coverage_table.tsv
# concoct --threads $threads --composition_file $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.contigs_10K.fa --coverage_file $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/$sample_id.coverage_table.tsv -b $output_folder/10_binning/$sample_id/$sample_id.concoct/
# merge_cutup_clustering.py $output_folder/10_binning/$sample_id/$sample_id.concoct/clustering_gt1000.csv > $output_folder/10_binning/$sample_id/$sample_id.concoct/clustering_merged.csv
# extract_fasta_bins.py $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa $output_folder/10_binning/$sample_id/$sample_id.concoct/clustering_merged.csv --output_path $output_folder/10_binning/$sample_id/$sample_id.concoct/bins
# checkm lineage_wf -t $threads -x fa -f $output_folder/10_binning/$sample_id/$sample_id.concoct.checkm/checkm.txt $output_folder/10_binning/$sample_id/$sample_id.concoct/bins $output_folder/10_binning/$sample_id/$sample_id.concoct.checkm/

# @adcho bin refinement with DAS Tools Here
# @adcho bin abundance calculations

# taxonomy
# @adcgo add bin taxonomy ID step
echo Classifying clean short-reads, unmapped short-reads, and contigs...
kraken2 --db $kraken_db1 --threads $threads $clean_short_reads --output $output_folder/11_taxonomy/1_unmapped/$sample_id.unmapped.standard.output --report $output_folder/11_taxonomy/1_unmapped/$sample_id.unmapped.standard.report --classified-out $output_folder/11_taxonomy/1_unmapped/$sample_id.unmapped.standard.classified --use-names
kraken2 --db $kraken_db2 --threads $threads $clean_short_reads --output $output_folder/11_taxonomy/1_unmapped/$sample_id.unmapped.plants.output --report $output_folder/11_taxonomy/1_unmapped/$sample_id.unmapped.plants.report --classified-out $output_folder/11_taxonomy/1_unmapped/$sample_id.unmapped.plants.classified --use-names
kraken2 --db $kraken_db1 --threads $threads $output_folder/07_fasta_ready/$sample_id.ready.fasta --output $output_folder/11_taxonomy/2_shortreads/$sample_id.shortreads.standard.output --report $output_folder/11_taxonomy/2_shortreads/$sample_id.shortreads.standard.report --classified-out $output_folder/11_taxonomy/2_shortreads/$sample_id.shortreads.standard.classified --use-names
kraken2 --db $kraken_db2 --threads $threads $output_folder/07_fasta_ready/$sample_id.ready.fasta --output $output_folder/11_taxonomy/2_shortreads/$sample_id.shortreads.plants.output --report $output_folder/11_taxonomy/2_shortreads/$sample_id.shortreads.plants.report --classified-out $output_folder/11_taxonomy/2_shortreads/$sample_id.shortreads.plants.classified --use-names
kraken2 --db $kraken_db1 --threads $threads $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa --output $output_folder/11_taxonomy/3_contigs/$sample_id.contigs.standard.output --report $output_folder/11_taxonomy/3_contigs/$sample_id.contigs.standard.report --classified-out $output_folder/11_taxonomy/3_contigs/$sample_id.contigs.standard.classified --use-names
kraken2 --db $kraken_db2 --threads $threads $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa --output $output_folder/11_taxonomy/3_contigs/$sample_id.contigs.plants.output --report $output_folder/11_taxonomy/3_contigs/$sample_id.contigs.plants.report --classified-out $output_folder/11_taxonomy/3_contigs/$sample_id.contigs.plants.classified --use-names
# using kraken-tools we could combine the standard report and plants report since were are RAM-limited

# genes
echo Predicting genes...
prokka  --cpus $threads --outdir $output_folder/12_genes/prokka/ --force --prefix $sample_id.bacteria.prokka $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa
prokka --cpus $threads --kingdom Archaea --outdir $output_folder/12_genes/prokka/ --force --prefix $sample_id.archaea.prokka $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa
prodigal -i $output_folder/08_megahit_contigs/$sample_id.$megahit_preset.megahit/final.contigs.fa -o $output_folder/12_genes/prodigal/$sample_id.prodigal.output -a 12_genes/prodigal/$sample_id.prodigal.faa
