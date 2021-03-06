library(snpStats)
dDir<-"/scratch2/vyp-scratch2/cian/UCLex_July2015/LDAK_gene_tests_all_phenos_good"
folders<-list.dirs(dDir,full.names=T)
files<-paste0(folders,"/regressALL")
nb.folders<-length(folders) 
file.list<-data.frame(matrix(nrow=length(files),ncol=5))

cohort.list<-c('Levine','Davina','Hardcastle','IoO','IoN','IoOFFS','IoONov2013','IoOPanos','Kelsell','LambiaseSD',
'Lambiase_','LayalKC','Manchester','Nejentsev','PrionUnit','Prionb2','Shamima','Sisodiya','Syrris','Vulliamy','WebsterURMD','gosgene')

file.list[,1]<-files
file.list[,2]<-basename(dirname(files)) 
file.list[,3]<-gsub(gsub(file.list[1:nb.folders,2],pattern="_\\..*",replacement=""),pattern=".*_",replacement="")
file.list[,4]<-file.exists(files)

file.list$TK<-FALSE
file.list$TK[grep("full",file.list[,2])]<-"fullTK"
file.list$TK[grep("TK_maf",file.list[,2])]<-"TK"
file.list$TK[grep("perm",file.list[,2])]<-"Permuted"
file.list$TK[grep("^no",file.list[,2])]<-"Basic"
file.list$TK[grep("Depth",file.list[,2])]<-"Depth"
file.list$TK[grep("TK_Depth_",file.list[,2])]<-"TK_Depth"

#file.list<-file.list[-grep("TK_Depth",file.list$TK),]
colnames(file.list)<-c("file","modelTK","cohort","file.exists","model","TK")


for(i in 1:length(cohort.list)) ## want to get maf and callrate for the gene tests, not hte kinships themselves. 
{
	hit<-grep(cohort.list[i],file.list$file )
	if(length(hit)>0)
	{
		file.list$cohort[hit]<-cohort.list[i]
	}#

}

source("qqchisq.R")
pdf('quick.plots.ldak.perm.pdf')
par(mfrow=c(2,2))
file.list<-file.list[order(file.list$cohort),]
for(i in 1:nrow(file.list))
{
	if(file.exists(file.list$file[i]))
	{
	dat<-read.table(file.list$file[i],header=T,sep=' ')
	print(file.list$file[i])
	qq.chisq(-2*log(dat$LRT_P_Perm), df=2,main=basename(dirname(file.list$file[i])),x.max=30,pvals=T,cex.main=.7)
	}
}
dev.off()

pdf('quick.plots.ldak.raw.pdf')
par(mfrow=c(2,2))
file.list<-file.list[order(file.list$cohort),]
for(i in 1:nrow(file.list))
{
	if(file.exists(file.list$file[i]))
	{
	dat<-read.table(file.list$file[i],header=T,sep=' ')
	print(file.list$file[i])
	qq.chisq(-2*log(dat$LRT_P_Raw), df=2,main=basename(dirname(file.list$file[i])),x.max=30,pvals=T,cex.main=.7)
	}
}
dev.off()



print('Done quick plots')



file.list$CallRate<-NA
file.list$MAF<-NA
annotate<-TRUE
if(annotate)
{
for(i in 1:length(cohort.list)) ## want to get maf and callrate for the gene tests, not hte kinships themselves. 
{
	hit<-grep(cohort.list[i],file.list$file )
	if(length(hit)>0)
	{
		file.list$cohort[hit]<-cohort.list[i]
		cohort.string.end<-as.numeric(gregexpr(cohort.list[i],file.list$modelTK[hit]))+nchar(cohort.list[i]) 
		short<-substr(file.list$modelTK[hit],cohort.string.end,nchar(file.list$modelTK[hit] ) ) 
		shorter<-gsub(short,pattern='_missing_',replacement='') 
		if(cohort.list[i]=='IoO')file.list$modelTK[file.list$cohort==cohort.list[i]]<-gsub(file.list$modelTK[file.list$cohort==cohort.list[i]],pattern='IoO_',replacement='IoO')
		tra<-t(data.frame(strsplit(shorter,"_") ))
		dat<-data.frame(matrix(nrow=nrow(tra),ncol=2))
		colnames(dat)<-c("CallRate","MAF") 
		dat[,1]<-gsub(paste0(tra[,1],tra[,2]) ,pattern="maf",replacement="")
		dat[,2]<-tra[,ncol(tra)]
		file.list$CallRate[hit]<-dat$CallRate
		file.list$MAF[hit]<-dat$MAF
	}#

}
} # annotate
file.list<-file.list[file.list$cohort%in%cohort.list,]
cohorts<-unique(file.list[,3])

var.dir<-"/scratch2/vyp-scratch2/cian/UCLex_June2015/KinshipDecomposition_all/"
var.files<-list.files(var.dir,pattern="progress",full.names=T) 
var.names<-basename(var.files)


fullTK.var.dir<-"/scratch2/vyp-scratch2/cian/UCLex_June2015/KinshipDecomposition/"
fullTK.var.files<-list.files(fullTK.var.dir,pattern="_tech.progress",full.names=T) 
fullTK.var.names<-basename(fullTK.var.files)

source("qqchisq.R")
oFile<-"uclex_feb_vary_tk.pdf"
pdf(oFile)
par(mfrow=c(2,2))
for(i in 1:length(cohorts))
{
	models<-file.list[which(file.list$cohort==cohorts[i] & file.list$file.exists),]
	models<-models[order(models$TK),]
	if(nrow(models)>0)
	{
	for( model in 1:nrow(models))
	{
#		if(models$TK[model]=="fullTK")var.explained<-"fullTK"
		if(models$TK[model]=="Basic")var.explained<-"Basic"
		if(models$TK[model]=="Permuted")var.explained<-"Permuted"
		if(models$TK[model]=="TK")
		{
			if( models$MAF[model]=="0000001") models$MAF[model]<-'000000001'
			kin<- substr(basename(dirname(models$file[model])),1,gregexpr(models$cohort[model],basename(dirname(models$file[model])))[[1]][1]-2)
			kin.name<- paste0(var.dir,models$cohort[model],"_",kin,".progress") 
		
			paste0(var.dir,models$cohort[model],'_TK_0.',models$MAF[model],'_0.',models$CallRate[model])
			if(file.exists(kin.name))
			{			
				kin.file<-read.table(kin.name,header=T,sep="\t") 
				var.explained<-paste0("TK-",kin.file$Her_K1[nrow(kin.file)] *100,"%")
			}	else var.explained<-"TK var not found"	
		}	


		if(models$TK[model]=="fullTK")
		{
#			if( models$MAF[model]=="0000001") models$MAF[model]<-'000000001'
			kin<- substr(basename(dirname(models$file[model])),1,gregexpr(models$cohort[model],basename(dirname(models$file[model])))[[1]][1]-2)
			kin.name<- paste0(fullTK.var.dir,models$cohort[model],"_tech.progress") 
			paste0(var.dir,models$cohort[model],'_TK_0.',models$MAF[model],'_0.',models$CallRate[model])
			if(file.exists(kin.name))
			{			
				kin.file<-read.table(kin.name,header=T,sep="\t") 
				var.explained<-paste0("fullTK-",kin.file$Her_K1[nrow(kin.file)] *100,"%")
			}	else var.explained<-"TK var not found"	
		}	

		if(models$TK[model]=="Depth")
		{
			if( models$MAF[model]==".000001") models$MAF[model]<-'00001'
			kin<- substr(basename(dirname(models$file[model])),1,gregexpr(models$cohort[model],basename(dirname(models$file[model])))[[1]][1]-2)
			kin.name<- paste0(var.dir,models$cohort[model],"_",kin,".progress") 
		
			paste0(var.dir,models$cohort[model],'_TK_0.',models$MAF[model],'_0.',models$CallRate[model])
			if(file.exists(kin.name))
			{			
				kin.file<-read.table(kin.name,header=T,sep="\t") 
				var.explained<-paste0("Depth-",kin.file$Her_K1[nrow(kin.file)] *100,"%")
			}	else var.explained<-"TK var not found"	
		}


		dat<-read.table(models$file[model],header=T,sep=" ")
		print(models$modelTK[model])
		qq.chisq(-2*log(dat$LRT_P_Perm),df=2,x.max=30,pvals=T,main= paste(models$cohort[model],var.explained, "maf",models$MAF[model],"CallRate",models$CallRate[model]),cex.main=0.8)
	}
	}	
}
dev.off()
message("done first plot") 
res.files<-list.files("/scratch2/vyp-scratch2/cian/UCLex_June2015/KinshipDecomposition_all/",pattern="indi.res",full.names=T) 
pdf("phenotype_vs_residuals.pdf") 
par(mfrow=c(2,2))
for(i in 1:length(res.files))
{
	file<-read.table(res.files[i],header=T,sep="\t") 
	plot(file$Phenotype,file$Residual,main=sub(basename(res.files[i]),pattern="_tech.*",replacement="")) 
}
dev.off()
