## Run after plot_singleVariant_results.R to get more detailed stats about interesting variants. 
library(HardyWeinberg)
library(biomaRt)
## Some data and links to start
release<-'June2015'
ldak<-'/cluster/project8/vyp/cian/support/ldak/ldak'
bDir<-paste0("/scratch2/vyp-scratch2/cian//UCLex_",release,"/") 
data<-paste0(bDir,'allChr_snpStats_out') 
func <- c("nonsynonymous SNV", "stopgain SNV", "nonframeshift insertion", "nonframeshift deletion", "frameshift deletion",
                "frameshift substitution", "frameshift insertion",  "nonframeshift substitution", "stoploss SNV",'splicing','exonic;splicing')
lof <-  c("frameshift deletion", "frameshift substitution", "frameshift insertion",  "stoploss SNV"
                ,"stopgain SNV"
                )


## Do initial filtering, by pvalue, quality, extCtrl maf and function/LOF status
variant.filter<-function(dat,pval=0.0001,pval.col="TechKinPvalue",func.filt=TRUE, lof.filt=FALSE,max.maf=1) 
{
	message("Filtering data")
	clean<-subset(dat, dat$FILTER=="PASS") 
	pval.col.nb<-colnames(clean)%in%pval.col
	sig<-subset(clean,clean[,pval.col.nb]<=pval) 
	funcy<-sig[sig$ExonicFunc %in% func,]
#	rare<- funcy[funcy$ExtCtrl_MAF < max.maf,]
	return(funcy)
	#return(rare) 
}#

## Get calls for variants that are left after filtering. 
prepData<-function(file,snp.col="SNP")
{
	snps<-file[,colnames(file)%in%snp.col]
	write.table(snps,paste0(bDir,"tmp"),col.names=F,row.names=F,quote=F,sep="\t") 
	message("Extracting variants from full file") 
	system( paste(ldak, "--make-sp tmp --bfile", data, "--extract", paste0(bDir,"tmp") )) 
	message("Reading variants into R session") 
	calls<-read.table("tmp_out.sp",header=F)
	fam<-read.table("tmp_out.fam",header=F)
	bim<-read.table("tmp_out.bim",header=F) 
	rownames(calls)<-bim[,2]
	colnames(calls)<-fam[,1]
	return(calls)
}


############# Now do fisher test
## data is the data.frame/matrix of calls, rows are variants. cases is the character vector of phenotype to be treated as cases. 
doFisher<-function(data, cases="Syrris")
{
	case.cols<-grep(cases, colnames(data)) 
	ctrl.cols<-which(!grepl(cases, colnames(data)) )

	## make dataframe for results
	colNamesDat <- c("SNP",  "FisherPvalue", "nb.mutations.HCM", "nb.mutations.ARVC", "nb.HCM", "nb.ARVC", 
	"HCM.maf", "ARVC.maf" , "nb.Homs.HCM", "nb.Homs.ARVC", "nb.Hets.HCM", "nb.Hets.ARVC",
	"nb.NAs.HCM", "nb.NAs.ARVC") 
	dat <- data.frame(matrix(nrow = nrow(calls), ncol = length(colNamesDat) ) )
	colnames(dat) <- colNamesDat
	dat[,1] <- rownames(calls) 

	message("Starting fisher tests")
	## calc fisher pvals
	for(i in 1:nrow(data))
	{
	if(i%%50==0)message(paste(i, 'tests done'))
	case.calls <-  t(as.matrix(calls[i,case.cols]))
	ctrl.calls <- t(as.matrix(calls[i,ctrl.cols]) )

	number_Homs_cases <- length(which(unlist(case.calls) == 2))
	number_Homs_ctrls <- length(which(unlist(ctrl.calls) == 2))

	case.hom.major <- length(which(unlist(case.calls) == 0))
	case.hets<- length(which(unlist(case.calls) == 1))
	case.freqs <- c(case.hom.major, case.hets, number_Homs_cases)
	case.maf <- maf(case.freqs)

	ctrl.hom.major <- length(which(unlist(ctrl.calls) == 0))
	ctrl.hets<- length(which(unlist(ctrl.calls) == 1))
	ctrl.freqs <- c(ctrl.hom.major, ctrl.hets, number_Homs_ctrls)
	ctrl.maf <- maf(ctrl.freqs)	

	flip<-FALSE
	if(flip) # doesnt work
	{
	if(number_Homs_cases>case.hom.major) ## fix minor allele switch. doesnt affect pvalue/maf calcs but looks stupid
	{
	tmp<-case.hom.major
	case.hom.major<-number_Homs_cases
	number_Homs_cases<-tmp
	case.calls[which(unlist(case.calls) == 2)]<-3
	case.calls[which(unlist(case.calls) == 0)]<-2
	case.calls[which(unlist(case.calls) == 3)]<-0
	}
	if(number_Homs_ctrls>ctrl.hom.major)
	{
	tmp<-ctrl.hom.major
	ctrl.hom.major<-number_Homs_ctrls
	number_Homs_ctrls<-tmp
	ctrl.calls[which(unlist(ctrl.calls) == 2)]<-3
	ctrl.calls[which(unlist(ctrl.calls) == 0)]<-2
	ctrl.calls[which(unlist(ctrl.calls) == 3)]<-0
	}	
	}

	number_mutations_cases <- sum( case.calls , na.rm=T )
	number_mutations_ctrls <- sum( ctrl.calls , na.rm=T ) 

	nb.nas.cases <- length(which(is.na(case.calls)))
	nb.nas.ctrls <- length(which(is.na(ctrl.calls)))

	nb.cases <-  length(which(!is.na( case.calls )) ) 
	nb.ctrls <-  length(which(!is.na( ctrl.calls )) ) 
		
	mean_number_case_chromosomes <- nb.cases * 2
	mean_number_ctrl_chromosomes <- nb.ctrls * 2

	if (!is.na(number_mutations_cases)  & !is.na(number_mutations_ctrls)  )
	{
	if (nb.cases > 0 & nb.ctrls > 0)
	{
		fishertest <-  fisher.test((matrix(c(number_mutations_cases, mean_number_case_chromosomes
		                         - number_mutations_cases, number_mutations_ctrls, mean_number_ctrl_chromosomes - number_mutations_ctrls),
		                       nrow = 2, ncol = 2)))


	dat$FisherPvalue[i] <- fishertest$p.value 
	dat$nb.mutations.HCM[i] <- number_mutations_cases
	dat$nb.mutations.ARVC[i]<- number_mutations_ctrls
	dat$nb.HCM[i]<- nb.cases 
	dat$nb.ARVC[i] <- nb.ctrls 
	dat$nb.NAs.HCM[i] <- nb.nas.cases 
	dat$nb.NAs.ARVC[i] <- nb.nas.ctrls
	dat$nb.Homs.HCM[i]<- number_Homs_cases
	dat$nb.Homs.ARVC[i]<- number_Homs_ctrls	
	dat$HCM.maf[i]<- case.maf
	dat$ARVC.maf[i]	<- ctrl.maf
	dat$nb.Hets.HCM[i] <- case.hets
	dat$nb.Hets.ARVC[i] <- ctrl.hets

	}
	}
} # for(i in 1:nrow(data))

colnames(dat)<-gsub(colnames(dat), pattern="HCM", replacement=cases) 
colnames(dat)<-gsub(colnames(dat), pattern="ARVC", replacement="ctrls") 
dat<-dat[order(dat$FisherPvalue),]
message("Finished Fisher tests")
return(dat)
} # End of function 



#########################################
######### Now run
#########################################
dataDir<-paste0("/scratch2/vyp-scratch2/cian/UCLex_",release,"/FastLMM_Single_Variant_all_phenos/") 
files<-list.files(dataDir,pattern='final',full.names=T)
names<-gsub(basename(files),pattern="_.*",replacement='')

for(i in 1:length(files))
{
	print(paste("Reading in",names[i]))
	file<-read.table(files[i],header=T,sep="\t",stringsAsFactors=F) 
	file$TechKinPvalue<-as.numeric(file$TechKinPvalue)
	filt<-variant.filter(file,pval=.000001) 
	calls<-prepData(filt)
	pvals<-doFisher(calls,cases=names[i]) 

	merged<-merge(filt, pvals,by="SNP") 
	ensembl = useMart("ensembl",dataset="hsapiens_gene_ensembl")
	filter="ensembl_gene_id"
	attributes =  c("ensembl_gene_id", "external_gene_name",  "phenotype_description")
	gene.data <- getBM(attributes= attributes , filters = filter , values = merged$Gene , mart = ensembl)
	gene.data.uniq <- gene.data[!duplicated(gene.data$external_gene_name),]

	anno<-merge(merged,gene.data.uniq,by.x='Gene',by.y='ensembl_gene_id')
	anno<-anno[order(anno$FisherPvalue),]
	anno$Pvalue<-as.numeric(as.character(anno$Pvalue))
	anno$TechKinPvalue<-as.numeric(as.character(anno$TechKinPvalue))

	write.table(anno, paste0(names[i],'_single_variant_vs_UCLex.csv'), col.names=T,row.names=F,quote=T,sep=",") 
}