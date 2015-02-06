#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

release=October2014
bDir="/cluster/project8/vyp/cian/data/UCLex/UCLex_October2014/Lambiase_case_control/whole_exome/gene_based"

ldak="/cluster/project8/vyp/cian/support/ldak/ldak"
data='/scratch2/vyp-scratch2/cian/UCLex_October2014/Genotype_Matrix.sp_out'
genes="/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt"
# extract=$bDir"/SNPs.func.ldak" ; role="Func"
# kinship=$bDir"/SADSvsUCLex_plink_func_snps_kinship"; kin="func"
# phenotypes=$bDir"/SADSvsUCLex_Pheno" ; pheno="SADSvsUCL"
Groups="/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/Groups"
TestingGroups="/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/TestingGroups"
maf=0
missing=0.9
minVar=1e-4
maxmaf=0.5

baseLDAK="/cluster/project8/vyp/cian/support/ldak/ldak.out" ## two versions of LDAK in use, this one older as it does not yet use permutations to calculate the pvalue when a kinship is included. 

oDir=$bDir"/LDAK/overlap_min_weight5_perm_no_kin_maf_"$maf"_${role}_${pheno}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights YES --partition-length 50000 --extract $extract --overlap NO --min-weight 5
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno 1 --ignore-weights YES --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --permute YES --extract $extract --maxmaf $maxmaf  --overlap NO --min-weight 5
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done

oDir=$bDir"/LDAK/overlap_min_weight5_no_kin_maf_"$maf"_${role}_${pheno}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights YES --partition-length 50000  --extract $extract --overlap NO --min-weight 5
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno 1 --ignore-weights YES --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --extract $extract --maxmaf $maxmaf --overlap NO --min-weight 5
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done


oDir=$bDir"/LDAK/overlap_min_weight5_${kin}_with_kin_maf_${maf}_${role}_${pheno}/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$baseLDAK --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights YES --partition-length 50000 --extract $extract --overlap NO --min-weight 5
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$baseLDAK  --calc-genes-reml $oDir --bfile $data --pheno $phenotypes --mpheno 1 --ignore-weights YES --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --grm $kinship --extract $extract --maxmaf $maxmaf --overlap NO --min-weight 5
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done 


