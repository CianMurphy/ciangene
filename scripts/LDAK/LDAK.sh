
#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

release=February2015
bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/LDAK_gene_tests_all_phenos/

ldak="/cluster/project8/vyp/cian/support/ldak/ldak"
data=/scratch2/vyp-scratch2/cian/UCLex_${release}/allChr_snpStats_out
genes="/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt"
# extract=$bDir"/SNPs.func.ldak" ; role="Func"
kinship=$bDir"/SADSvsUCLex_plink_func_snps_kinship"; kin="func"
# phenotypes=$bDir"/SADSvsUCLex_Pheno" ; pheno="SADSvsUCL"
Groups="/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/Groups"
TestingGroups="/cluster/project8/vyp/cian/data/UCLex/UCLex_${release}/TestingGroups"
maf=0.000001	
missing=0.9
minVar=1e-4
maxmaf=0.5





oDir="perm_no_kin_maf_${maf}_${role}_${pheno}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $bDir$oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights YES --partition-length 50000 --extract $extract --overlap NO --min-weight 3
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml $bDir$oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights YES --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --permute YES --extract $extract --maxmaf $maxmaf  --overlap NO --min-weight 3
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done

oDir="no_kin_maf_${maf}_${role}_${pheno}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $bDir$oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights YES --partition-length 50000  --extract $extract --overlap NO --min-weight 3
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml $bDir$oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights YES --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --extract $extract --maxmaf $maxmaf --overlap NO --min-weight 3
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done

exit

oDir="${kin}_with_kin_maf_${maf}_${role}_${pheno}/"
rm -fr $oDir ; mkdir $oDir
$ldak --cut-genes $bDir$oDir --genefile $genes --bfile $data  --gene-buffer 20000 --ignore-weights YES --partition-length 50000 --extract $extract --overlap NO --min-weight3
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak --calc-genes-reml $bDir$oDir --bfile $data --pheno $phenotypes --mpheno $mPheno --ignore-weights YES --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --grm $kinship --extract $extract --maxmaf $maxmaf --overlap NO --min-weight 3
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done 


