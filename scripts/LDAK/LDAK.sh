
#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

release=February2015
bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/LDAK_gene_tests_all_phenos/

#### Data
ldak="/cluster/project8/vyp/cian/support/ldak/ldak"
data=/scratch2/vyp-scratch2/cian/UCLex_${release}/allChr_snpStats_out
genes="/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt"
kinship=/scratch2/vyp-scratch2/cian/UCLex_${release}/TechKin; kin="func"
Groups="/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/Groups"
TestingGroups="/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/TestingGroups"
runSh='sh /cluster/project8/vyp/cian/scripts/bash/runBashCluster.sh'
####### Parameters
#minMaf=0.000001	
#missing=0.7
minVar=1e-4
maxmaf=0.5
power=0 ## rare variants arent upweighed with power = 0
minWeight=3 # genes need min this many variants to be included
overlap=NO # variants counted once per region, no overlapping transcripts
ignoreWeights=YES ## if YES, variants arent weighted for LD correction
#######



##### Permuted with no techKin. 
oDir=$bDir"perm_${pheno}_${missing}_${maxmaf}_${minMaf}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 50000 --extract $extract --overlap $overlap --min-weight $minWeight
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minmaf $minMaf \
--minvar $minVar --minobs $missing --partition $partition --permute YES --extract $extract --maxmaf $maxmaf  --overlap $overlap --min-weight $minWeight --power $power
" > $oDir$oFile
cd $oDir ; $runSh $oFile ; cd .. 
done


### REML no Kinship
oDir=$bDir"no_kin_${pheno}_${missing}_${maxmaf}_${minMaf}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 50000  --extract $extract --overlap $overlap --min-weight $minWeight
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minmaf $minMaf \
--minvar $minVar --minobs $missing --partition $partition --extract $extract --maxmaf $maxmaf --overlap $overlap --min-weight $minWeight  --power $power
" > $oDir$oFile
cd $oDir ; $runSh $oFile ; cd .. 
done


### REML technical kinship
oDir=$bDir"with_kin_${pheno}_${missing}_${maxmaf}_${minMaf}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights $ignoreWeights --partition-length 50000 --extract $extract --overlap $overlap --min-weight $minWeight
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights $ignoreWeights --minmaf $minMaf \
 --minvar $minVar --minobs $missing --partition $partition --grm $kinship --extract $extract --maxmaf $maxmaf --overlap $overlap --min-weight $minWeight  --power $power
" > $oDir$oFile
cd $oDir ; $runSh $oFile ; cd .. 
done 


