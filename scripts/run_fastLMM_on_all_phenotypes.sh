#/bin/sh

shopt -s expand_aliases
source ~/.bashrc

nbGroups=$(tail -1 ../nb.groups | awk '{print $1}') 
echo $nbGroups "phenotypes for fastLMM to chew on"

templateScript="fastlmm.template.sh"

oFolder="FastLMM_Single_Variant_all_phenos"
rm -r $oFolder ; mkdir $oFolder

for pheno in $(seq 1 $nbGroups)
do
batch=$(sed -n $pheno'p' ../Groups)
target=$oFolder"/"$batch".fastlmm.sh"
# cp $templateScript $target
oFile=$batch"_Out"

echo "
	release=October2014

	bDir='/cluster/project8/vyp/cian/data/UCLex/UCLex_"'${release}'"/Gene_tests/Clean_Up/'


	fastlmm='/share/apps/bahler/FaSTLMM.207/Bin/Linux_MKL/fastlmmc'
	snpFile='/scratch2/vyp-scratch2/cian/UCLex_"'${release}'"/Genotype_Matrix_ext_ctrls_removed'
	kinshipFile='/cluster/project8/vyp/cian/data/UCLex/UCLex_"'${release}'"Lambiase_case_control/single_variant/LambiaseVsUCLex_fastLMM_tech_kinship'
	phenoFile='/cluster/project8/vyp/cian/data/UCLex/UCLex_"'${release}'"/All_phenotypes/All_phenotypes'
	covar='/scratch2/vyp-scratch2/cian/UCLex_"'${release}'"/Lambiase_case_control/IVF_all_pcs.vect'
	extract='/cluster/project8/vyp/cian/data/UCLex/UCLex_"'${release}'"/Lambiase_case_control/whole_exome/gene_based/SNPs.func_extract'

	"'$fastlmm'"  -simLearnType Full -verboseOutput -maxThreads 1 -bfile "'$snpFile'" -sim "'$kinshipFile'" -pheno "'$phenoFile'" -mpheno "$pheno" -out "$batch"_Tech_kin -extract "'$extract'"
	"'$fastlmm'"  -linreg -simLearnType Full -verboseOutput -maxThreads 1 -bfile "'$snpFile'" -pheno "'$phenoFile'" -mpheno "$pheno" -out "$batch"_no_kin -extract "'$extract'"
	" >> $target

cd $oFolder ; runSh $batch".fastlmm.sh" ; cd ..
done



