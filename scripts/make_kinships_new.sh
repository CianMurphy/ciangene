ldak=/cluster/project8/vyp/cian/support/ldak/ldak


## got to update this
	# DO i still want to bother calculating genotype weights if im not using them 
	# no need for read depth kin
	## use calc-kins-direct instead of cutting and joining. probably slower but more convenient. 

rootODir=/scratch2/vyp-scratch2/ciangene
release=February2015

rootODir=$1
release=$2


bDir=${rootODir}/UCLex_${release}

missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing"
techOut=$bDir"/Technical_Kinship"


## Some basic parameters: 
## minObs=0.9 			## SNP needs to be present in 90% samples to be included. 
minMaf=0.000001			## SNP with MAF >= this are retained
minVar=0.001			## SNP with variance >= this are retained? 
## maxTime=500			## Nb minutes calculation allowed run for. 
hwe=0.0001

ldak --calc-kins-direct $techOut --bfile $missingNonMissing --ignore-weights YES --kinship-raw YES --minmaf $minMaf --minvar  $minVar --hwe $hwe






