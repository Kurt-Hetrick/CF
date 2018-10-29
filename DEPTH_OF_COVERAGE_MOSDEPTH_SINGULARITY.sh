#!/bin/bash

# tell sge to submit any of these queue when available
#$ -q rnd.q,prod.q,test.q,bigdata.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -1020

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

	# set

	# echo

# INPUT VARIABLES

	INPUT_CRAM=$1
		SM_TAG=$(basename $INPUT_CRAM .cram)
	OUTPUT_DIR="/home/khetric1/DEPTH_OF_COVERAGE/OUTPUT"
	
	mkdir -p $OUTPUT_DIR

# OTHER VARIABLES

	CODING_BED="/home/khetric1/DEPTH_OF_COVERAGE/gencodev24_coding_short_primary_rough_sort_merged.bed"
	REFERENCE_GENOME="/home/khetric1/DEPTH_OF_COVERAGE/Homo_sapiens_assembly38.fasta"

# CMD LINE to generate depth of coverage stats

	singularity exec /home/khetric1/DEPTH_OF_COVERAGE/mosdepth-0.2.3.simg mosdepth \
		-t 4 \
		-b $CODING_BED \
		-n \
		-f $REFERENCE_GENOME \
		-Q 20 \
		$OUTPUT_DIR/$SM_TAG \
		$INPUT_CRAM

# summarizing and normalizing

	zcat $OUTPUT_DIR/$SM_TAG".regions.bed.gz" \
		| awk 'BEGIN {OFS="\t"} $1~/^chr[0-9]/ {print $1,"AUTO",($3-$2),($3-$2)*$4,$4} \
			$1=="chrX" {print $1,"X",($3-$2),($3-$2)*$4,$4} \
			$1=="chrY" {print $1,"Y",($3-$2),($3-$2)*$4,$4}' \
		| singularity exec /home/khetric1/DEPTH_OF_COVERAGE/datamash.simg datamash \
			-g 2 \
			sum 3 \
			sum 4 \
			sstdev 5 \
		| awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$3/$2,$4}' \
		| cut -f 4,5 \
		| singularity exec /home/khetric1/DEPTH_OF_COVERAGE/datamash.simg datamash transpose \
		| paste - - \
		| awk 'BEGIN {print "#SAMPLE" , "MEAN_AUTO" , "MEAN_X" , "MEAN_Y" , "NORM_X" , "NORM_Y" , "AUTO_SD"} \
			{print "'$SM_TAG'" , $1 , $2 , $3 , ($2/$1) , ($3/$1) , $4}' \
		| sed 's/ /\t/g' \
	>| $OUTPUT_DIR/$SM_TAG".GENDER_CHECK.txt"

# pull out CFTR exons and normalize by autosomal mean

	AUTO_MEAN=`awk 'NR==2 {print $2}' $OUTPUT_DIR/$SM_TAG".GENDER_CHECK.txt"`
	AUTO_SD=`awk 'NR==2 {print $7}' $OUTPUT_DIR/$SM_TAG".GENDER_CHECK.txt"`

	singularity exec /home/khetric1/DEPTH_OF_COVERAGE/tabix-1.7.simg tabix \
		$OUTPUT_DIR/$SM_TAG".regions.bed.gz" \
		chr7:117480094-117667108 \
		| awk 'BEGIN {print "#SAMPLE" , "CHROM" , "START" , "STOP" , "MEAN_DEPTH" , "EXON_NUMBER" , "NORM_DEPTH" , "AUTO_MEAN_SD"} \
			{print "'$SM_TAG'" , $0 , NR , ($4/"'$AUTO_MEAN'") , "'$AUTO_SD'" }' \
		sed 's/ /\t/g' \
	>| $OUTPUT_DIR/$SM_TAG".CFTR.exons.txt"
