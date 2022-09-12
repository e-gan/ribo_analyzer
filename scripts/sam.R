#!/usr/bin/env Rscript
args <-commandArgs(trailingOnly=TRUE)
minLen <- strtoi(args[1])
maxLen <- strtoi(args[2])

library("dada2")

# Forward and reverse fastq filenames have format: SAMPLENAME_R1_001.fastq and SAMPLENAME_R2_001.fastq
fnFs <- sort(list.files('./',pattern="_NA_sequence.fastq", full.names = TRUE))
#fnFs <- sort(c('211001Voi_D21-8926_CUT.fastq.gz','211001Voi_D21-8927_CUT.fastq.gz','211001Voi_D21-8930_CUT.fastq.gz','211001Voi_D21-8931_CUT.fastq.gz','211001Voi_D21-8932_CUT.fastq.gz'))
#fnRs <- sort(list.files(path, pattern="_R2_001_CUT.fastq", full.names = TRUE))
print(fnFs)

#print(fnFs)

# Extract sample names, assuming filenames have format: SAMPLENAME_S_XXX.fastq
sample.names <- sapply(strsplit(basename(fnFs), "_NA"), `[`, 1)
print(sample.names)

# Place filtered files in filtered/ subdirectory
filtFs <- file.path(paste('filtered.',as.character(minLen),'.',as.character(maxLen),sep=''), paste0(sample.names, "_F_filt.fastq.gz"))
#filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))

names(filtFs) <- sample.names
#names(filtRs) <- sample.names

outF <- filterAndTrim(fnFs, filtFs,
                      maxN=0, truncQ=2, rm.phix=TRUE,minLen=minLen, maxLen=maxLen,
                      compress=FALSE, multithread=TRUE) # On Windows set multithread=FALSE

head(outF)
