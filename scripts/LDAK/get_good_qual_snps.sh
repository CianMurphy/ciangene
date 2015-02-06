R CMD BATCH get_good_qual_snps.R
awl '{print $1}' SNP.data > SNP.data.extract
