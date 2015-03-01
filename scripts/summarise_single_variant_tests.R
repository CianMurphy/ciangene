release <- "February2015"

bDir <- paste0("/scratch2/vyp-scratch2/cian/UCLex_", release, "/")

fisherDir <- paste0(bDir, "Single_variant_tests/") 
fisher <- list.files(fisherDir, pattern = "assoc.fisher", full.names=T )
groups <- gsub(basename(fisher), pattern = "_.*", replacement = "")

logistic.base <- list.files(fisherDir, pattern = "logistic_no_covars.assoc.logistic.adjusted", full.names=T) 
logistic.tech <- list.files(fisherDir, pattern = "logistic_tech_pcs_covars.assoc.logistic.adjusted", full.names=T) 

for(i in 1:length(fisher))
{
	file <- read.table(fisher[i], header=T)



}