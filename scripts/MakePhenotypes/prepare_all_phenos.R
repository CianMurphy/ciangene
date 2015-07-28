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
#############################################
oDir <- paste0(rootODir, "/UCLex_", release, "/")
source("/cluster/project8/vyp/cian/data/UCLex/ciangene/scripts/MakePhenotypes/make_phenotype_file.R")
source("/cluster/project8/vyp/cian/data/UCLex/ciangene/scripts/MakePhenotypes/CaseControl_support.R")

groups<-read.table( paste0(oDir, "cohort.summary"), header=T,sep="\t")

#data<-'/scratch2/vyp-scratch2/cian/UCLex_February2015_bk/allChr_snpStats_out'

pheno<-read.table(paste0(oDir,"Phenotypes"),header=F,sep="\t") 
ancestry<-read.table(paste0(oDir,"UCLex_samples_ancestry",header=T,sep="\t")
keep<-subset(ancestry,ancestry$Caucasian)
pheno[pheno[,1]%in%keep[,1],3:ncol(pheno)]<-NA
syrris<-removeConflictingControls(pheno,remove=c("Lambiase") ,cases=pheno[grep("Syrris",pheno[,1]),1]) 
lambiase<-removeConflictingControls(syrris,remove=c("Syrris"),cases=pheno[grep("Lambiase",pheno[,1]),1]  ) 


pheno<-lambiase  ## or last modified pheno file 
for(i in 1:nrow(groups))
{
	pheno<-makeExternalControls(pheno,cases=groups$Cohort[i],data=paste0(oDir,"/allChr_snpStats_out"),oBase=paste0(oDir,"/",groups$Cohort[i]) ) 
}


## fastLMM wants missing as -9, so use separate pheno file. 
pheno[is.na(pheno)] <- '-9'
write.table(pheno,paste0(inPheno,"_fastlmm"), col.names=F, row.names=F, quote=F, sep="\t")

###### make permuted phenotype file for fastLMM/plink 
for(i in 1:nb.groups)
{
	nb.cases <- length(which(pheno[,i+2]==2)) 
	pheno[,i+2] <- 1 
	pheno[sample(1:nrow(pheno),nb.cases),i+2] <- 2
}
write.table(pheno,paste0(inPheno,"_fastlmm_permuted"), col.names=F, row.names=F, quote=F, sep="\t")