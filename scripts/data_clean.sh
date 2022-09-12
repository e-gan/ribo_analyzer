#!/bin/bash
#Runs cutadapt, dada2, then bowtie2
#Current directory must store:
#	-this bash script
#	-Rscript
#	-bowtie alignment files
#	-fastq files

#Inputs:
#	-a adapter
#		CTGTAGGCACCATCAAT (march, april, jan)
#		AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC (sep)
#	-m minimum length of read
#	-M maximum length of read

#srun --pty bash


#interpret input
while getopts a:m:M: flag
do
    case "${flag}" in
        a) adapter=${OPTARG};;
        m) min=${OPTARG};;
        M) max=${OPTARG};;
    esac
done

#load modules
module load python cutadapt bowtie2
mkdir -p stats
mkdir -p cut

#run cutadapt
#modify filenames as necessary
for i in $(find ./ -type f -name '_NA_sequence.fastq');
do 
base=$(basename $i "_NA_sequence.fastq") 
echo ${i}
(cutadapt --discard-untrimmed -m 10 -a $adapter -o cut/${base}\_CUT.fastq.gz ${i}) |& tee -a "stats/Sep2021_cutadapt_info.txt"
done

#unload python, reload conda
module unload python
source /home/software/conda/miniconda3/bin/condainit

#if first time running, need to build R env and download dada2
#conda create -n r_env r-essentials r-base
#conda activate r_env
#also must downgrade Matrix package to v. 1.3.2

conda activate r_env

#run dada2
Rscript sam.R $min $max
conda deactivate

#run bowtie2
module load python
mkdir -p sam.$min.$max
mkdir -p sam.$min.$max/unmapped

for i in filtered.$min.$max/*_F_filt.fastq.gz; 
do 
base=$(basename $i "_F_filt.fastq.gz")
(echo ${base}) &>> "stats/Sep2021_align.$min.$max.txt"
(bowtie2 --phred33 --local -N 0 -L 19 --un sam.$min.$max/unmapped/ -x E_Coli -U filtered.$min.$max/${base}_F_filt.fastq.gz -S sam.$min.$max/${base}.sam) 2>>  "stats/Sep2021_align.$min.$max.txt"
done
