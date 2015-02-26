getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'February2015'

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]

######################

library(snpStats)
library(GenABEL)

files <- list.files(pattern = "flt_Tech") 
batches <- gsub(files, pattern = ".*Func_", replacement = "")

groups <- read.table("/cluster/project8/vyp/cian/data/UCLex/UCLex_October2014/All_phenotypes/Nb_per_group", header=F ) 
colnames(groups) <- c("Cohort", "SampleSize") 
groups$GenomicInflationTech <- 0 
groups$GenomicInflationPerm <- 0 

oFile <- "UCLex_October_all_samples_model_comparison.pdf"
pdf(oFile)
par(mfrow=c(2,2), cex.main = 0.6) 

	for(i in 1:length(files)) 
	{
		permFile <- paste0(files[i], "/regress1")
		if(file.exists(permFile))
		{
		file <- read.table(permFile , header=T)		
		pvals=pchisq(file$Perm_1,1,lower=F)*0.5
		#gi <- qq.chisq(-2*log(as.numeric(as.character(pvals))), df=2, x.max=30, main = paste(batches[i], "Perm"), pvals=T)
		
		gi <- estlambda(file$Perm_1, df =2 , plot=T, main = paste(batches[i], "Perm")) $estimate
		hit <- grep(batches[i], groups[,1] ) 		
		groups$GenomicInflationPerm[hit] <- gi[[3]]
		}

		techFile <- paste0(files[i], "/regressALL")
		if(file.exists(techFile)) 
		{	
		file <- read.table(techFile , header=T)		
		pvals <- as.numeric(as.character(file$LRT_P_Perm))

		#gi <-	qq.chisq(-2*log(pvals), df=2, x.max=30, main = paste(batches[i], "Tech"), pvals=T)

		gi <- estlambda(file$Perm_1, df =2 , plot=T, main = paste(batches[i], "Tech") )$estimate
		hit <- grep(batches[i], groups[,1] ) 		
		groups$GenomicInflationTech[hit] <- gi[[3]]
		}
	}	

dev.off()

groups <- groups[order(groups$GenomicInflationPerm),]
