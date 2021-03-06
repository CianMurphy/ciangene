getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'July2015'
rootODir<-'/scratch2/vyp-scratch2/cian'

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]

######################
bDir <- paste0(rootODir, "/UCLex_", release, "/")
ldak<-'/cluster/project8/vyp/cian/support/ldak/ldak'
minMaf<-0 
maxMaf<-.5
maxMiss<-2
hwe.pval<-0.00001 

#annotations<-read.csv(paste0(bDir,'annotations.snpStat'),header=T,sep="\t")
ex.ctrl<-list.files(paste0(bDir,"External_Control_data/"),pattern='ctrls.frq',full.names=T)
ex.ctrl.hwe<-list.files(paste0(bDir,"External_Control_data/"),pattern='hwe',full.names=T)
ex.ctrl.case<-list.files(paste0(bDir,"External_Control_data/"),pattern='case_qc.lmiss',full.names=T)
names<-gsub(basename(ex.ctrl),pattern="_.*",replacement="")

func <- c("nonsynonymous SNV", "stopgain SNV", "nonframeshift insertion", "nonframeshift deletion", "frameshift deletion",
                "frameshift substitution", "frameshift insertion",  "nonframeshift substitution", "stoploss SNV",'splicing','exonic;splicing')
lof <-  c("frameshift deletion", "frameshift substitution", "frameshift insertion",  "stoploss SNV"
                ,"stopgain SNV"
                )

annotations$isFunc<-FALSE
annotations$isFunc[annotations$Func%in%func|annotations$ExonicFunc%in%func]<-TRUE
#annotations$ESP6500si_ALL[is.na(annotations$ESP6500si_ALL)]<-0
#annotations$X1000g2012apr_ALL[is.na(annotations$X1000g2012apr_ALL )]<-0 
clean<-subset(annotations,annotations$FILTER=='PASS'&annotations$isFunc & annotations$ESP6500si_ALL <= maxMaf & annotations$X1000g2012apr_ALL <= maxMaf )$clean.signature

for(i in 1:length(ex.ctrl))
{
	print(ex.ctrl[i])
	system(paste('tr -s " " < ', ex.ctrl[i],'>', paste0(ex.ctrl[i],"_clean") ) ) 
	file<-read.table(paste0(ex.ctrl[i],"_clean"),header=T)
	system(paste('tr -s " " < ', ex.ctrl.case[i],'>', paste0(ex.ctrl.case[i],"_clean") ) ) 
	hwe<-read.table(ex.ctrl.hwe[i],header=T) 
	hwe<-subset(hwe,hwe$TEST=="ALL")
	hwe.good.snps<-hwe$SNP[hwe$P>hwe.pval] 
	case<-read.table(paste0(ex.ctrl.case[i],"_clean"),header=T) 
	case.miss<-case$SNP[case$F_MISS<=maxMiss]
	variants<-file$SNP[file$SNP%in%clean&file$MAF<=maxMaf&file$SNP%in%case.miss&file$SNP%in%hwe.good.snps]
	oFile<-paste0(bDir,"External_Control_data/",names[i],"_rare_func_variants")
	write.table(variants,file=oFile,col.names=F,row.names=F,quote=F,sep='\t')
}



