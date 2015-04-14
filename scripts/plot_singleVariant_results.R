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
minMaf <- c(0, 0.00001,0.01,0.1,0.2)
count.thresholds <- c(0,100,500,1000)

iDir <- paste0(bDir, "FastLMM_Single_Variant_all_phenos/")

models<-c("no_kin","Tech_kin","perm","res")
AllFiles<-list.files(iDir,full.names=TRUE)
if(length(grep('sh',AllFiles))>0)AllFiles<- AllFiles[-grep('sh',AllFiles)]
if(length(grep('merged',AllFiles))>0)AllFiles<- AllFiles[-grep('merged',AllFiles)]
if(length(grep('pdf',AllFiles))>0)AllFiles<- AllFiles[-grep('pdf',AllFiles)]

Collate<-function(group,model)
{
	model.files<-AllFiles[grep(model,AllFiles)]
	files<-model.files[grep(paste0(group,"_"),model.files)]
	if(length(files)>0)
	{
		for(i in 1:length(files))
		{
			oFile<-paste0(iDir,model,"_",group,"_merged")
			#if(!file.exists(oFile))
			#{
				message(paste('Merging into',oFile))
				file<-read.table(files[i],header=T,sep="\t") 
				if(i==1)write.table(file,oFile,col.names=T, row.names=F, quote=F, sep="\t", append=F) 
				if(i>1)write.table(file,oFile,col.names=F, row.names=F, quote=F, sep="\t", append=T) 
			#} else message(paste(oFile,'already exists, so skipping'))
		}
	} else message("No files match input, wtf")
}

groups <- gsub(basename(AllFiles[grep("Tech",AllFiles)]), pattern = "_.*", replacement = "")
uniq.groups <- unique(groups)
start.group <- 8 
end.group<-length(uniq.groups)

prep<-TRUE
if(prep)
{
	for(i in start.group:end.group) 
	{
		for(mod in 1:length(models))
		{
			Collate(uniq.groups[i],models[mod])
		}
	}
}

files <- list.files(iDir, pattern = "merged", full.names=TRUE)

noKin <- files[grep('no_kin',files)]
techKin <-files[grep('Tech',files)]
permy <- files[grep('perm',files)]
inRes<-files[grep('res',files)]

counts <- list.files(paste0(bDir, "Single_variant_tests/") , pattern = "assoc$", full.names=TRUE) 
noCovar <- list.files(paste0(bDir, "Single_variant_tests/") , pattern = ".*no.*adjusted", full.names=TRUE)
techCovar <- list.files(paste0(bDir, "Single_variant_tests/") , pattern = ".*tech.*adjusted", full.names=TRUE)

annotations <- read.csv(paste0(bDir, "annotations.snpStat"), header=TRUE, sep="\t")
extCtrl <- read.table(paste0(bDir, "Ext_ctrl_variant_summary"), header=TRUE )
extCtrl.small <- data.frame(extCtrl[,1], extCtrl$MAF)
colnames(extCtrl.small) <-  c("SNP", "ExtCtrl_MAF") 
extCtrl.small$ExtCtrl_MAF[is.na(extCtrl.small$ExtCtrl_MAF)] <- 0 

oFile <- paste0(iDir, "SingleVariant_qqplots.pdf")
pdf(oFile)
par(mfrow=c(2,2), cex.main=0.8)
for(i in 1:length(uniq.groups))
{
	iBase <- noKin[grep(paste0("_",uniq.groups[i],"_"), noKin) ]
	iTech <- techKin[grep(paste0("_",uniq.groups[i],"_"), techKin) ]
	iCovar <- noCovar[grep(paste0(uniq.groups[i],"_"), noCovar) ]
	iTk <- techCovar[grep(paste0(uniq.groups[i],"_"), techCovar) ]
	iPerm <- permy[grep(paste0(uniq.groups[i],"_"), permy) ]
	iRes<-inRes[grep(paste0("_",uniq.groups[i],"_"),inRes) ]
	inputs <- c(iBase, iTech, iCovar, iTk, iPerm,iRes)
	if(length(which(file.exists(inputs)))==6)
	{
		message("Now processing ", uniq.groups[i])
		base <- read.table(iBase, header=T, stringsAsFactors=F)
		tech <- read.table(iTech, header=T, stringsAsFactors=F)
		tech.small <- data.frame(SNP=tech$SNP, TechKinPvalue=tech$Pvalue)
		perm <- read.table(iPerm, header=T, stringsAsFactors=F)
		perm.small <- data.frame(SNP=perm$SNP, permPvalue=perm$Pvalue)
		res <- read.table(iRes, header=T, stringsAsFactors=F)
		res.small <- data.frame(SNP=res$SNP, resPvalue=res$Pvalue)

		results.merged <- merge(base, tech.small, by = "SNP")
		results.merged2<-merge(results.merged, res.small, by = "SNP")
		results.merged3 <- merge(results.merged2,perm.small,by='SNP')
		results.merged.anno <- merge(results.merged3, annotations, by.x = "SNP", by.y ="clean.signature")

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
		message("Now plotting ", uniq.groups[i])
		lapply(count.thresholds,function(x)
		{
	#		dat <- data.frame(subset(results.merged.anno.extCtrl, results.merged.anno.extCtrl$ExtCtrl_MAF >= x )) 
			dat <- subset(final, final$C_U >= x )
			message(nrow(dat),' rows with counts greater than ',x)
			if(nrow(dat) > 0 )
			{
				qq.chisq(-2*log(as.numeric(dat$Pvalue)),df=2,x.max=30,pvals=T, main = paste(uniq.groups[i], x, "noKin",nrow(dat)))
				qq.chisq(-2*log(as.numeric(dat$TechKinPvalue)),df=2,x.max=30, pvals=T, main = paste(uniq.groups[i], x, "TechKin", nrow(dat)))
			}   
		}
		)
	} ## file.xists(hit)
} else message("Skipping " , uniq.groups[i]) # file.exists(inputs)
}
dev.off()
