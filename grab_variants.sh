#!/bin/bash

IN_VCF=$1 # input gatk vcf thas been decomposed.
	OUT_DIR=$(dirname $IN_VCF)
	VCF_NAME=$(basename $IN_VCF .gz | sed 's/.vcf//g' )

# IN_VCF="pilot_117470081-117677104.DandN.known_vep_variants_2.vcf"

module load datamash/1.1.0
# using bcftools 1.9 from anaconda 2-5.0.0.1

COUNT_COLUMNS=$(zgrep -m 1 ^#CHROM $IN_VCF \
	| awk '{print NF}')

rm -rvf variants.txt

GRAB_VARIANTS ()
{
	echo bcftools view -i "'ID=\"$HGVSCDNA\"'" \
	$IN_VCF \
		| bash \
		| grep -v "^##" \
		| cut -f 10-$COUNT_COLUMNS \
		| datamash transpose \
		| awk '$2~"1/1" {print "'$HGVSCDNA'",$1,"var_hom"} $2~"0/1" {print "'$HGVSCDNA'",$1,"het"}' \
		| sed 's/ /\t/g' \
		>> $OUT_DIR/$VCF_NAME".variants.txt"
}

for HGVSCDNA in $(zgrep -v "^#" $IN_VCF | cut -f 3 | sort)
do
	GRAB_VARIANTS
done
