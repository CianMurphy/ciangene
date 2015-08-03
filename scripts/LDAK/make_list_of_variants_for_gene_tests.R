release<-'June2015'
ldak<-'/cluster/project8/vyp/cian/support/ldak/ldak'
bDir<-paste0("/scratch2/vyp-scratch2/cian/UCLex_",release,"/") 
maxMaf<-.005
maxMiss<-.2

annotations<-read.csv(paste0(bDir,'annotations.snpStat'),header=T,sep="\t")
ex.ctrl<-list.files(paste0(bDir,"External_Control_data/"),pattern='ctrls.frq_clean',full.names=T)
ex.ctrl.case<-list.files(paste0(bDir,"External_Control_data/"),pattern='case_qc.lmiss',full.names=T)
names<-gsub(basename(ex.ctrl),pattern="_.*",replacement="")

func <- c("nonsynonymous SNV", "stopgain SNV", "nonframeshift insertion", "nonframeshift deletion", "frameshift deletion",
                "frameshift substitution", "frameshift insertion",  "nonframeshift substitution", "stoploss SNV",'splicing','exonic;splicing')
lof <-  c("frameshift deletion", "frameshift substitution", "frameshift insertion",  "stoploss SNV"
                ,"stopgain SNV"
                )

annotations$isFunc<-FALSE
annotations$isFunc[annotations$Func%in%func|annotations$ExonicFunc%in%func]<-TRUE
clean<-subset(annotations,annotations$FILTER=='PASS'&annotations$isFunc)$clean.signature

for(i in 1:length(ex.ctrl))
{
	file<-read.table(ex.ctrl[i],header=T)
	system(paste('tr -s " " < ', ex.ctrl.case[i],'>', paste0(ex.ctrl.case[i],"_clean") ) ) 
	case<-read.table(paste0(ex.ctrl.case[i],"_clean"),header=T) 
	case.miss<-case$SNP[case$F_MISS<=maxMiss]
	variants<-file$SNP[file$SNP%in%clean&file$MAF<=maxMaf&file$SNP%in%case.miss]
	oFile<-paste0(bDir,"External_Control_data/",names[i],"_rare_func_variants")
	write.table(variants,file=oFile,col.names=F,row.names=F,quote=F,sep='\t')
}



