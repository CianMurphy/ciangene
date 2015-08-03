getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'June2015'
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
inPheno<-paste0(oDir,"Phenotypes")
pheno<-read.table(inPheno,header=F,sep="\t") 

remove.caucasians<-FALSE
if(remove.caucasians)
{
	ancestry<-read.table(paste0(oDir,"UCLex_samples_ancestry"),header=T,sep="\t")
	keep<-subset(ancestry,ancestry$Caucasian)
	pheno[pheno[,1]%in%keep[,1],3:ncol(pheno)]<-NA
}

syrris<-removeConflictingControls(pheno,remove=c("Lambiase") ,cases=pheno[grep("Syrris",pheno[,1]),1],oDir=oDir) 
lambiase<-removeConflictingControls(syrris,remove=c("Syrris"),cases=pheno[grep("Lambiase_",pheno[,1]),1] ,oDir=oDir ) 
lambiaseSD<-removeConflictingControls(lambiase,remove=c("Syrris","Lambiase_"),cases=pheno[grep("LambiaseSD",pheno[,1]),1] ,oDir=oDir ) 
lambiaseSD[c(3797:3824,grep("ambiase",lambiaseSD[,1]) ),c(1,92,93,104)] ## check, syrris should be NA in cols 92 93, lambiase  and syrris NA in 92 and 94 and SD only na in 104. 


cohort.list<-c('Levine','Davina','Hardcastle','IoO','IoN','IoOFFS','IoONov2013','IoOPanos','Kelsell','LambiaseSD',
'Lambiase','LayalKC','Manchester','Nejentsev','PrionUnit','Prionb2','Shamima','Sisodiya','Syrris','Vulliamy','WebsterURMD')

if(!file.exists(paste0(oDir,"/External_Control_data/") ))dir.create(paste0(oDir,"/External_Control_data/") ) 
pheno<-lambiaseSD  ## or last modified pheno file 
for(i in 1:length(cohort.list))
{
	hit<-grep(cohort.list[i],groups$Cohort)
	if(cohort.list[i] == "IoO")	hit<-grep('IoO$',groups$Cohort)
	if(cohort.list[i] == "Lambiase") 	hit<-grep('Lambiase$',groups$Cohort)

	pheno<-makeExternalControls(pheno,cases=groups$Cohort[hit],data=paste0(oDir,"/allChr_snpStats_out"),oBase=paste0(oDir,"/External_Control_data/",groups$Cohort[hit]) ) 
}

write.table(pheno,inPheno, col.names=F, row.names=F, quote=F, sep="\t")

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
