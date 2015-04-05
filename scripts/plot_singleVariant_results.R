getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'February2015'
rootODir<-'/scratch2/vyp-scratch2/cian'

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]

######################
library(snpStats)

bDir <- paste0("/scratch2/vyp-scratch2/cian/UCLex_", release, "/")
minMaf <- c(0, 0.00001,  0.01, 0.1, 0.2)
count.thresholds <- c(0,100, 200, 500)

iDir <- paste0(bDir, "FastLMM_Single_Variant_all_phenos/")

noKin <- list.files(iDir, pattern = "no_kin", full.names=TRUE)
techKin <- list.files(iDir, pattern = "Tech_kin", full.names=TRUE)
groups <- gsub(basename(techKin) , pattern = "_.*", replacement = "")

uniq.groups <- unique(groups)
if(!file.exists(paste0(iDir, "noKin_", uniq.groups[1], "_merged")))
{
for(i in 1:length(uniq.groups)) 
{
	hit <- which(groups %in% uniq.groups[i]); message(uniq.groups[i]) 
	for(inp in 1:length(hit))
	{
		nok <- read.table(noKin[inp], header=T)
		tek <- read.table(techKin[inp], header=T)
		if(inp==1)
		{
			write.table(nok, paste0(iDir, "noKin_", uniq.groups[i], "_merged") , col.names=T, row.names=F, quote=F, sep="\t", append=F) 
			write.table(tek, paste0(iDir, "techKin_", uniq.groups[i], "_merged") , col.names=T, row.names=F, quote=F, sep="\t", append=F) 
		}
		if(inp>1)
		{	
			write.table(nok, paste0(iDir, "noKin_", uniq.groups[i], "_merged") , col.names=F, row.names=F, quote=F, sep="\t", append=T) 
			write.table(tek, paste0(iDir, "techKin_", uniq.groups[i], "_merged") , col.names=F, row.names=F, quote=F, sep="\t", append=T) 
		}
	}
}
} # file exists


noKin <- list.files(iDir, pattern = "noKin", full.names=TRUE)
techKin <- list.files(iDir, pattern = "techKin", full.names=TRUE)

counts <- list.files(paste0(bDir, "Single_variant_tests/") , pattern = "counts_assoc.qassoc.adjusted", full.names=T) 
noCovar <- list.files(paste0(bDir, "Single_variant_tests/") , pattern = ".*no.*adjusted", full.names=T)
techCovar <- list.files(paste0(bDir, "Single_variant_tests/") , pattern = ".*tech.*adjusted", full.names=T)

annotations <- read.csv(paste0(bDir, "annotations.snpStat"), header=T, sep="\t")
extCtrl <- read.table(paste0(bDir, "Ext_ctrl_variant_summary"), header=T )
extCtrl.small <- data.frame(extCtrl[,1], extCtrl$MAF)
colnames(extCtrl.small) <-  c("SNP", "ExtCtrl_MAF") 
extCtrl.small$ExtCtrl_MAF[is.na(extCtrl.small$ExtCtrl_MAF)] <- 0 

oFile <- paste0(iDir, "SingleVariant_qqplots.pdf")
pdf(oFile)
par(mfrow=c(2,2), cex.main=0.8)
for(i in 1:length(uniq.groups))
{
	iBase <- noKin[grep(uniq.groups[i], noKin) ]
	iTech <- techKin[grep(uniq.groups[i], techKin) ]
	iCovar <- noCovar[grep(uniq.groups[i], noCovar) ]
	iTk <- techCovar[grep(uniq.groups[i], techCovar) ]
	inputs <- c(iBase, iTech, iCovar, iTk)
	if(length(which(file.exists(inputs)))==4)
	{
	message(paste("Now plotting", uniq.groups[i]))
	base <- read.table(iBase, header=T, stringsAsFactors=F)
	tech <- read.table(iTech, header=T, stringsAsFactors=F)
	tech.small <- data.frame(SNP=tech$SNP, TechKinPvalue=tech$Pvalue)

	results.merged <- merge(base, tech.small, by = "SNP")
	results.merged.anno <- merge(results.merged, annotations, by.x = "SNP", by.y ="clean.signature")

	noCov <- read.table(iCovar, header=T, stringsAsFactors=F)
	noCov.small<-data.frame(SNP=noCov$SNP, noCov$UNADJ)
	tk <- read.table(iTk, header=T, stringsAsFactors=F)
	tk.small<-data.frame(SNP=tk$SNP,tk$UNADJ)
	covariate.pvalues<-merge(noCov.small, tk.small,by='SNP')

	results.merged.anno2 <- merge(results.merged.anno, covariate.pvalues,by='SNP')
	results.merged.anno.extCtrl <- merge(results.merged.anno2, extCtrl.small, by = "SNP")
	results.merged.anno.extCtrl$tk.UNADJ[which(is.infinite(results.merged.anno.extCtrl$tk.UNADJ) )] <- 1
	hit <- counts[grep(uniq.groups[i], counts)][1]
	if(file.exists(hit))
	{
	current.counts <- read.table(hit, header=T) 
	final <- merge(results.merged.anno.extCtrl, current.counts, by = "SNP")
	write.table(results.merged.anno.extCtrl, paste0(iDir, groups[i], "_filt"), col.names=T, row.names=F, quote=F, sep="\t")
#	lapply(minMaf, function(x)
	lapply(count.thresholds,function(x)
	{
#		dat <- data.frame(subset(results.merged.anno.extCtrl, results.merged.anno.extCtrl$ExtCtrl_MAF >= x )) 
		dat <- subset(final, final$C_U >= x )
		message(nrow(dat) )
		if(nrow(dat) > 0 )
		{
		qq.chisq(-2*log(as.numeric(dat$Pvalue)),df=2,x.max=30,pvals=T, main = paste(uniq.groups[i], x, "noKin",nrow(dat)))
		qq.chisq(-2*log(as.numeric(dat$TechKinPvalue)),df=2,x.max=30, pvals=T, main = paste(uniq.groups[i], x, "TechKin", nrow(dat)))
		}   
	}
	)

	} ## file.xists(hit)
} else message(paste("Skipping", uniq.groups[i])) # file.exists(inputs)
}
dev.off()
