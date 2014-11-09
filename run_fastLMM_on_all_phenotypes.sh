#/bin/sh

shopt -s expand_aliases
source ~/.bashrc

nbGroups=$(tail -1 ../nb.groups | awk '{print $1}') 
echo $nbGroups "phenotypes for fastLMM to chew on"

templateScript="fastlmm.template.sh"

oFolder="FastLMM_Single_Variant_with_tech_kin"
rm -r $oFolder ; mkdir $oFolder

for pheno in $(seq 1 $nbGroups)
do
batch=$(sed -n $pheno'p' ../Groups)
target=$oFolder"/"$batch".fastlmm.sh"
cp $templateScript $target
oFile=$batch"_Out"

finalLine=""'$fastlmm'" -simLearnType Full -verboseOutput -maxThreads 1 -bfile "'$snp_file'" -sim "'$kinship_file'" -pheno "'$phenotype_file'" -mpheno $pheno -out $oFile"
echo $finalLine >> $target

cd $oFolder ; runSh $batch".fastlmm.sh" ; cd ..
done
