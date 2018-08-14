#!/bin/bash

IN_VCF=$1 # needs to be bgzip (.gz) vcf with index (.tbi)
LOCI=$2 # chr[0-9]:start-stop
VARIANT=$3 # the CF name
RS_ID=$4 # dbsnp name

module load datamash/1.1.0

COUNT_COLUMNS=$(zgrep -m 1 ^#CHROM $IN_VCF \
	| awk '{print NF}')

tabix -h $IN_VCF $LOCI \
	| grep -v "^##" \
	| cut -f 10-$COUNT_COLUMNS \
	| datamash transpose \
	| egrep "JHU" \
	| awk '$2~"1/1" {print $1,"'$VARIANT'","'$RS_ID'","var_hom"} $2~"0/1" {print $1,"'$VARIANT'","'$RS_ID'","het"}' \
	| sed 's/ /\t/g'
