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

	set

	echo

# INPUT VARIABLES

	INPUT_CRAM=$1
		SM_TAG=$(basename $INPUT_CRAM .cram)
	OUTPUT_DIR=$2

	mkdir -p $OUTPUT_DIR

# I TOOK THE BINARY FROM GITHUB WHICH MEANS THAT I HAVE TO POINT LD_LIBRARY_PATH TO HTSLIB VERSION GREATER THAN 1.4

	export LD_LIBRARY_PATH="/mnt/linuxtools/ANACONDA/anaconda2-5.0.0.1/lib"

# OTHER VARIABLES

	CODING_BED="/mnt/research/tools/PIPELINE_FILES/GRCh38/gencodev24_coding_short_primary_rough_sort_merged.bed"
	REFERENCE_GENOME="/mnt/research/tools/PIPELINE_FILES/GRCh38/Homo_sapiens_assembly38.fasta"
	MOSDEPTH_DIR="/mnt/linuxtools/MOSDEPTH/0.2.3"
	module load datamash/1.1.0

# CMD LINE to generate depth of coverage stats

	$MOSDEPTH_DIR/mosdepth \
	-t 4 \
	-b $CODING_BED \
	-n \
	-f $REFERENCE_GENOME \
	-Q 20 \
	$OUTPUT_DIR/$SM_TAG \
	$INPUT_CRAM

# summarizing and normalizing

	zcat $OUTPUT_DIR/$SM_TAG".regions.bed.gz" \
		| awk 'BEGIN {OFS="\t"} $1~/^chr[0-9]/ {print $1,"AUTO",($3-$2),($3-$2)*$4} \
			$1=="chrX" {print $1,"X",($3-$2),($3-$2)*$4} \
			$1=="chrY" {print $1,"Y",($3-$2),($3-$2)*$4}' \
		| datamash -g 2 sum 3 sum 4 \
		| awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$3/$2}' \
		| cut -f 4 \
		| datamash transpose \
		| awk 'BEGIN {print "SAMPLE","MEAN_AUTO","MEAN_X","MEAN_Y","NORM_X","NORM_Y"} \
			{print "'$SM_TAG'",$1,$2,$3,$2/$1,$3/$1}' \
		| sed 's/ /\t/g' \
	>| $OUTPUT_DIR/$SM_TAG".GENDER_CHECK.txt"
