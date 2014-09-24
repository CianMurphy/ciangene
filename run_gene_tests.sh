#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

ldak="/cluster/project8/vyp/cian/support/ldak/ldak4.7"
data="/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_Matrix"
genes="/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt"
weights="/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_weights/re-weightsALL" 

kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"  ; kin="Tech"
#kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"   ; kin="Depth"


phenotypes="/scratch2/vyp-scratch2/cian/UCLex_August2014/All_phenotypes"
maf=0.00001
missing=0.9
minVar=0.00001

groups=$(wc -l Groups | awk '{print $1}' ) 

#for pheno in `seq 1 2`;
for pheno in `seq 1 $groups`;
	do   

out=$(sed -n "$pheno"'p' Groups)

oDir="perm_no_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/" ; echo $oDir >> dirs 
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --permute YES
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done



oDir="no_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/" ; echo $oDir >> dirs 
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar --minobs $missing --partition $partition 
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done

### First Kin 
kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"  ; kin="Tech"

oDir=$kin"_perm_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/" ; echo $oDir >> dirs 
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --grm $kinship --permute YES
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done



oDir=$kin"_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/" ; echo $oDir >> dirs 
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --grm $kinship 
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done 


############ Repeat gene tests with other kinship matrix. 
kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"   ; kin="Depth"

oDir=$kin"_perm_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/" ; echo $oDir >> dirs 
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --grm $kinship --permute YES
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done


oDir=$kin"_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/" ; echo $oDir >> dirs 
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar --minobs $missing --partition $partition --grm $kinship 
" > $oDir$oFile
cd $oDir ; runSh $oFile ; cd .. 
done 




done

exit

#############################################################################################################
################### 				How much variance does each kinship exxplain. 
############################################################################################################


oDir="how_much_variance_do_kinships_explain"
mkdir $oDir;cd $oDir

echo "
ldak="/cluster/project8/vyp/cian/support/ldak/ldak4.7"
phenotypes="/scratch2/vyp-scratch2/cian/UCLex_August2014/All_phenotypes"
aKinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"
bKinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/Depth_weights/kinshipALL"


groups=$(wc -l ../Groups | awk '{print $1}' ) 

for pheno in "'`seq 1 $groups`'" ;
do   
	out="'$(sed -n "$pheno"'p' ../Groups)'"

	"'$ldak'" --decompose tech --grm "'$aKinship'" 		
	"'$ldak'"  --reml "'$pheno'"_August.tech --grm "'$aKinship'" --pheno "'$phenotypes'" --mpheno "'$pheno'" --eigen blank


	"'$ldak'" --decompose depth --grm "'$bKinship'" 
	"'$ldak'" --reml "'$pheno'"_August.depth --grm "'$bKinship'" --pheno "'$phenotypes'" --mpheno "'$pheno'" --eigen blank
done
" > decompose.kinships.sh
runSh decompose.kinships.sh


#############################################################################################################
################### 				Gene tests with both kinships. 
############################################################################################################

# Firstly i want to take the residuals from one kinship decomposition and use it in the reml with the other kinship 
# as including both kinship matrices is too slow. 


tDir="/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/Gene_based_tests/how_much_variance_do_kinships_explain"

for f in $(find $tDir -name '*res') 
do
	echo $f
	awk '{ print $5 }' $f > $f'_residuals'
done



Kinship="/scratch2/vyp-scratch2/cian/UCLex_August2014/TechKin_weights/kinshipALL"


groups=$(wc -l Groups | awk '{print $1}' ) 

#for pheno in `seq 1 23`;
for pheno in `seq 1 $groups`;
	do   

out=$(sed -n "$pheno"'p' Groups)


kin="Both"
oDir=$kin"_with_kin_maf_"$maf"_pheno_$out"_missingness_"$missing/"
rm -fr $oDir ; mkdir $oDir
#echo "$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 " > tmp.sh ; runSh tmp.sh
$ldak --cut-genes $oDir --genefile $genes --bfile $data  --gene-buffer 20000 --weights $weights --partition-length 50000 
Partitions=$(tail -1 $oDir/gene_details.txt | awk '{print $2}')
for partition in $(seq 1 $Partitions)
do
oFile='partition_'$partition'.sh'
echo "
$ldak  --calc-genes-reml "../"$oDir --bfile $data --pheno $phenotypes --mpheno $pheno --weights $weights --minmaf $maf --minvar $minVar \
--minobs $missing --partition $partition --grm $Kinship --effects 
" > $oDir$oFile
# cd $oDir ; runSh $oFile ; cd .. 
done 

done








