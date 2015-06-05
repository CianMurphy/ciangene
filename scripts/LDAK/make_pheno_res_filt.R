kinDecom<-list.files("/scratch2/vyp-scratch2/cian/UCLex_February2015/KinshipDecomposition_flt", pattern ="indi.res",full.names=T) 
names<-gsub(basename(kinDecom),pattern="_.*",replacement="") 
write.table(names,"Res_filt_groups",col.names=F,row.names=F,quote=F,sep="\t") 
for(i in 1:length(kinDecom))
{
	file<-read.table(kinDecom[i],header=T, sep="\t") 
	if(i==1)
	{
		mat<-matrix(nrow=nrow(file), ncol=(length(kinDecom)+2) ) 
		mat[,1]<-file[,1]
		mat[,2]<-file[,2]
		mat[,3]<-file[,ncol(file)]
	}else
	{
		mat[,i+2]<-file[,ncol(file)]
	}
}

write.table(mat,"Res_filt_phenotype_file",col.names=F,row.names=F,quote=F,sep="\t") 


