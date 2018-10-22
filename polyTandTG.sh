#!/bin/bash

VCF="/mnt/research/cf/CFTR/PILOT/pilot_117470081-117677104.vcf.gz"
LOCUS="chr7:117548606-117548630"
OUTDIR="/mnt/research/cf/CFTR/PILOT"


tabix -h $VCF \
$LOCUS \
	| grep -v ^## \
	| cut -f 10-277 \
	| datamash transpose \
	| awk 'BEGIN {OFS="\t"} \
		{split($2,a,":"); \
		split($3,b,":"); \
		split($4,c,":"); \
		split($5,d,":"); \
		split($6,e,":"); \
		if ( a[1]=="0/0" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/0" && e[1]=="0/0" ) \
			print $1 , "11TG;7T" , "11TG;7T" ; \
		else if ( a[1]=="0/0" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/1" && e[1]=="0/0" ) \
			print $1 , "11TG;7T" , "10TG;9T" ; \
		else if ( a[1]=="0/0" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/1" && e[1]=="0/2" ) \
			print $1 , "10TG;9T" , "12TG;5T" ; \
		else if ( a[1]=="0/0" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="1/1" && e[1]=="0/0" ) \
			print $1 , "10TG;9T" , "10TG;9T" ; \
		else if ( a[1]=="0/0" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="1/2" && e[1]=="0/0" ) \
			print $1 , "10TG;9T" , "11TG;9T" ; \
		else if ( a[1]=="0/0" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="1/3" && e[1]=="0/1" ) \
			print $1 , "10TG;9T" , "11TG;5T" ; \
		else if ( a[1]=="0/0" && b[1]=="0/1" && c[1]=="0/1" && d[1]=="0/1" && e[1]=="0/0" ) \
			print $1 , "9TG;9T" , "10TG;9T" ; \
		else if ( a[1]=="0/1" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/0" && e[1]=="0/0" ) \
			print $1 , "10TG;7T" , "11TG;7T" ; \
		else if ( a[1]=="0/1" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/1" && e[1]=="0/0" ) \
			print $1 , "10TG;7T" , "10TG;9T" ; \
		else if ( a[1]=="0/1" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/3" && e[1]=="0/1" ) \
			print $1 , "10TG;7T" , "11TG;5T" ; \
		else if ( a[1]=="0/2" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/0" && e[1]=="0/0" ) \
			print $1 , "11TG;7T" , "12TG;7T" ; \
		else if ( a[1]=="0/2" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/1" && e[1]=="0/0" ) \
			print $1 , "12TG;7T" , "11TG;5T" ; \
		else if ( a[1]=="1/1" && b[1]=="0/0" && c[1]=="0/0" && d[1]=="0/0" && e[1]=="0/0" ) \
			print $1 , "10TG;7T" , "10TG;7T" ; \
		else print $1 , "UNKNOWN" , "PLEASE_CHECK"}' \
	| awk 'BEGIN {print "Subject_ID" "\t" "polyTG_T_Allele_1" "\t" "polyTG_T_Allele_2"} \
		{print $0}' \
>> $OUTDIR/polyTG_T_GT.txt
