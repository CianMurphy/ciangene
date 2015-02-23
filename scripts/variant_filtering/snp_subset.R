library(snpStats)

missingness.threshold <- .9 # snps need to be present in missingness.threshold % of cases and controls

release <- 'October2014'

dir <- paste0("/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_", release , "/mainset_", release, "_by_chr")
files <- list.files(dir, pattern ="_snpStats.RData", full.names=T) 
files <- files[order(as.numeric(gsub(gsub(basename(files), pattern ="chr", replacement =""), pattern = "_.*", replacement = "") ) )]
chr <- gsub(gsub(files, pattern = ".*/chr", replacement = "" ) , pattern = "_snpStats.RData", replacement = "") 
oDir <- paste0("/scratch2/vyp-scratch2/cian/UCLex_", release, "/Sanity_Check/SNP_filtering/")
if(!file.exists(oDir)) dir.create(oDir)

cases <- "Hardcastle"
caseOFile <- paste0(oDir, cases, "_case_snp_summary")
ctrlOFile <-  paste0(oDir, cases, "_ctrl_snp_summary")

if(!file.exists(caseOFile))
{
	for(i in 1:length(files))
	{ 
		load(files[i])
		message(files[i])

		case.snps <- matrix.calls.snpStats[ grep(cases, rownames(matrix.calls.snpStats)) , ] 
		ctrl.snps <- matrix.calls.snpStats[ -grep(cases, rownames(matrix.calls.snpStats)) , ] 

		case.var.summary <- col.summary(case.snps) 
		ctrl.var.summary <- col.summary(ctrl.snps) 

		if(i==1) write.table(case.var.summary, file = caseOFile, col.names=T, row.names=T, quote=F, sep="\t", append = F) 
		if(i>1) write.table(case.var.summary, file = caseOFile, col.names=F, row.names=T, quote=F, sep="\t", append = T) 

		if(i==1) write.table(ctrl.var.summary, file = ctrlOFile, col.names=T, row.names=T, quote=F, sep="\t", append = F) 
		if(i>1) write.table(ctrl.var.summary, file = ctrlOFile, col.names=F, row.names=T, quote=F, sep="\t", append = T)

	}
}



case.sum <- read.table(caseOFile, header=T ) 
ctrl.sum <- read.table(ctrlOFile, header=T) 

dat <- data.frame(case.sum, ctrl.sum) 
dat.flt <- subset(dat, dat$Call.rate >= missingness.threshold & dat$Call.rate.1 >= missingness.threshold ) 

write.table(rownames(dat.flt), file = paste0(oDir, cases, "_clean_snps"), col.names=F, row.names=F, quote=F, sep="\t") 
