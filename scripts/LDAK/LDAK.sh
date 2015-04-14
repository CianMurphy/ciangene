#!/bin/bash

#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}
bDir=${rootODir}/UCLex_${release}/LDAK_gene_tests_all_phenos_flt/


#### Data
ldak=/cluster/project8/vyp/cian/support/ldak/ldak
data=$rootODir/UCLex_${release}/allChr_snpStats_out
#kinship=$rootODir/UCLex_${release}/TechKin
kinship=/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/ciangene/scripts/TK_Subset/TechKinFiltered
genes=/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt

####### Parameters
#minMaf=0.000001	
#missing=0.7
minVar=1e-4
maxmaf=0.5
power=0 # rare variants arent upweighed with power = 0
minWeight=3 # genes need min this many variants to be included
overlap=NO # variants counted once per region, no overlapping transcripts
ignoreWeights=YES ## if YES, variants arent weighted for LD correction
partition=1
#######


### REML no Kinship
oDir=$bDir"/no_kin_${pheno}_${missing}_${minMaf}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 2000000  --extract $extract --overlap $overlap --min-weight $minWeight

$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minvar $minVar --minobs $missing \
 --extract $extract --minmaf $minMaf --maxmaf $maxmaf --overlap $overlap --min-weight $minWeight  --power $power --partition $partition 


##### Permuted with no techKin. 
oDir=$bDir"/perm_${pheno}_${missing}_${minMaf}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 2000000 --extract $extract --overlap $overlap --min-weight $minWeight

$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minvar $minVar --minobs $missing \
 --extract $extract --minmaf $minMaf --maxmaf $maxmaf --overlap $overlap --min-weight $minWeight  --power $power --partition $partition --permute YES


### REML technical kinship
oDir=$bDir"/with_kin_${pheno}_${missing}_${minMaf}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 2000000 --extract $extract --overlap $overlap --min-weight $minWeight

$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minvar $minVar --minobs $missing \
 --extract $extract --minmaf $minMaf --maxmaf $maxmaf --overlap $overlap --min-weight $minWeight --power $power --partition $partition --grm $kinship



