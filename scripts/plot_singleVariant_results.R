getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'February2015'

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]

######################
library(snpStats)

bDir <- paste0("/scratch2/vyp-scratch2/cian/UCLex_", release, "/")

iDir <- paste0(bDir, "FastLMM_Single_Variant_all_phenos/")

noKin <- list.files(iDir, pattern = "no_kin", full.names=TRUE)
techKin <- list.files(iDir, pattern = "Tech_kin", full.names=TRUE)

groups <- gsub(basename(techKin) , pattern = "_.*", replacement = "")

annotations <- read.csv(paste0(bDir, "annotations.snpStat"), header=T, sep="\t")
extCtrl <- read.table(paste0(bDir, "Ext_ctrl_variant_summary"), header=T )
extCtrl.small <- data.frame(extCtrl[,1], extCtrl$MAF)
colnames(extCtrl.small) <-  c("SNP", "ExtCtrl_MAF") 
extCtrl.small$ExtCtrl_MAF[is.na(extCtrl.small$ExtCtrl_MAF)] <- 0 

minMaf <- c(0, 0.00001, 0.0001, 0.001, 0.01, 0.1, 0.2)

oFile <- paste0(iDir, "SingleVariant_qqplots.pdf")

pdf(oFile)
for(i in 1:length(groups))
{

	base <- read.table(noKin[i], header=T)
	tech <- read.table(techKin[i], header=T)
	tech.small <- data.frame(tech$SNP, tech$Pvalue)
	colnames(tech.small) <- c("SNP", "TechKinPvalue")

	results.merged <- merge(base, tech, by = "SNP")

	results.merged.anno <- merge(results.merged, annotations, by.x = "SNP", by.y ="clean.signature")

	results.merged.anno.extCtrl <- merge(results.merged.anno, extCtrl.small, by = "SNP")

	write.table(results.merged.anno.extCtrl, paste0(iDir, groups[i], "_filt"), col.names=T, row.names=F, quote=F, sep="\t")


	lapply(minMaf, function(x)
	{
		dat <- subset(results.merged.anno.extCtrl, results.merged.anno.extCtrl$ExtCtrl_MAF >= ExtCtrl_MAF)
		qq.chisq(-2*log(dat$Pvalue), df=2, x.max=30, pvals=T, main = paste(groups[i], x, "noKin"))
		qq.chisq(-2*log(dat$TechKinPvalue), df=2, x.max=30, pvals=T, main = paste(groups[i], x, "TechKin"))
	}
	)

}
dev.off()











