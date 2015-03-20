ldak=/cluster/project8/vyp/cian/support/ldak/ldak
data=/scratch2/vyp-scratch2/cian/UCLex_October2014/Sanity_Check/UCLex_October_genotypes_out
oDir=/scratch2/vyp-scratch2/cian/UCLex_October2014/Sanity_Check/SNP_filtering/
extract=$oDir"Hardcastle_clean_snps"

minMaf=0.000001			## SNP with MAF >= this are retained
minVar=0.001	

$ldak --make-bed $oDir"Genotype.small" --bfile $data --extract $extract
$ldak --calc-kins-direct $oDir"TechKin.small" --bfile $oDir"Genotype.small" --ignore-weights YES --kinship-raw YES --minmaf $minMaf --minvar  $minVar
