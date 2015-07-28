plink<-'/share/apps/genomics/plink-1.07-x86_64/plink --noweb --allow-no-sex --bfile'

removeConflictingControls<-function(basePheno,remove,cases)
{
	# basePheno is initial pheno file, eg the one from make_phenotype_file.R
	case.rows<-basePheno[basePheno[,1]%in% cases,]
	case.col<-which(case.rows[1,3:ncol(case.rows)]==2)+2
	case.coldata<-basePheno[,case.col]
	for(i in 1:length(remove))
	{
		if(i==1)filtPheno<-basePheno
		hit<-grep(remove[i],basePheno[,1])
		if(length(hit)==0){ warning(paste("No samples called" ,remove[i],"found"))}else{
			filtPheno[hit,case.col]<-NA
		}
	}
return(filtPheno)
}

makeExternalControls<-function(pheno,cases,data,oBase,percent=10)
{
	# pheno is phenotype file, preferably with any conflicting controls removed. 
	# list of case names
	# percent is what percent of controls i want to use as my external control set. 
	# data is stem for bam file 
	hit<-grep(cases[i],pheno[,1])
	filt<-pheno[-hit,]
	nas<-which(is.na(filt[,1]) )
	if(length(nas>0))filt<-filt[-nas,] 

	nb.ex.ctrl<-round(nrow(filt)/percent) 
	ex.ctrls<-filt[sample(1:nrow(filt),nb.ex.ctrl),1]	

	newPheno<-filt[!filt[,1]%in%ex.ctrls,]
	write.table(data.frame(ex.ctrls,ex.ctrls),paste0(oBase,"_ex_ctrls"),col.names=F,row.names=F,quote=F)

	oDir<-paste0(oBase,"External_Control_data")
	if(!file.exists)dir.create(oDir)
	run<-paste( plink,data, '--freq --out',  paste0(oDir,"_ex_ctrls") ,'--keep', paste0(oBase,"_ex_ctrls") ) 
	system(run)
	run<-paste( plink,data, '--hardy --out',  paste0(oDir,"_ex_ctrls") ,'--keep', paste0(oBase,"_ex_ctrls") ) 
	system(run)

	return(newPheno)
}


