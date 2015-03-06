#/bin/sh

shopt -s expand_aliases
source ~/.bashrc

release=February2015
bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/
Groups=$bDir"GroupNames"
nbGroups=$(wc -l  $Groups | awk '{print $1}') 

echo $nbGroups "phenotypes for fastLMM to chew on"

oFolder=$bDir"FastLMM_Single_Variant_all_phenos/"
rm -r $oFolder ; mkdir $oFolder

for pheno in $(seq 73 $nbGroups)
do

batch=$(sed -n $pheno'p' $Groups)
target=$oFolder"/"$batch".fastlmm.sh"
oFile=$oFolder$batch"_Out"

echo "
	release=February2015

	bDir=/scratch2/vyp-scratch2/cian/UCLex_${release}/

	fastlmm='/share/apps/bahler/FaSTLMM.207/Bin/Linux_MKL/fastlmmc'
	snpFile=$bDir"allChr_snpStats_out"
	kinshipFile=$bDir"TechnicalKinship_Fastlmm"
	phenoFile=$bDir"Phenotypes"
	extract=$bDir"Clean_variants_Func"

	"'$fastlmm'"  -simLearnType Full -verboseOutput -maxThreads 1 -bfile "'$snpFile'" -sim "'$kinshipFile'" -pheno "'$phenoFile'" -mpheno "$pheno" -out "$batch"_Tech_kin -extract "'$extract'"
	"'$fastlmm'"  -linreg -simLearnType Full -verboseOutput -maxThreads 1 -bfile "'$snpFile'" -pheno "'$phenoFile'" -mpheno "$pheno" -out "$batch"_no_kin -extract "'$extract'"
	" >> $target

# cd $oFolder ; runSh $batch".fastlmm.sh" ; cd ..
cd $oFolder ; sh $batch".fastlmm.sh" ; cd ..
done


