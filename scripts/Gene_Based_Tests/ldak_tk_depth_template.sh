#!/bin/bash

#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/LDAK_gene_tests_all_phenos_new/


#### Data
ldak=/cluster/project8/vyp/cian/support/ldak/ldak.4.8
data=$rootODir/UCLex_${release}/allChr_snpStats_out
genes=/cluster/project8/vyp/cian/data/genes

####### Parameters
minVar=1e-4
maxmaf=0.5
power=0 # rare variants arent upweighed with power = 0
minWeight=3 # 3 # genes need min this many variants to be included
overlap=NO # variants counted once per region, no overlapping transcripts
ignoreWeights=YES ## if YES, variants arent weighted for LD correction
partition=1
#######

### REML technical kinship
oDir=$bDir/TK_Depth_${pheno}_missing_${missing}_maf_${minMaf}
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 2000000 --extract $extract --overlap $overlap --min-weight $minWeight

$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minvar $minVar --minobs $missing \
 --extract $extract --minmaf $minMaf --maxmaf $maxmaf --overlap $overlap --min-weight $minWeight --power $power --partition $partition
