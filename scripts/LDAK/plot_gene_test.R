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

oDir <- paste0("/scratch2/vyp-scratch2/cian/UCLex_", release, "/") 

files <- list.files(paste0(oDir, "LDAK_gene_tests_all_phenos/"), pattern = "with_kin", full.names=T) 
batches <- gsub(files, pattern = ".*Func_", replacement = "")

groups <- read.table(paste0(oDir, "cohort.summary"), header=T) 
groups$GenomicInflationTech <- 0 
groups$GenomicInflationPerm <- 0 
groups$GenomicInflationBase <- 0 

noKins <- paste0(oDir, "LDAK_gene_tests_all_phenos/no_kin_maf_0.000001_Func_", batches, "/regressALL")


oFile <- paste0(oDir, "UCLex_", release, "_gene_tests.pdf") 
pdf(oFile)
par(mfrow=c(2,2), cex.main = 0.6) 

	for(i in 1:length(files)) 
	{

		if(file.exists(noKins[i]))
		{
		file <- read.table(noKins[i] , header=T)		
		GI <- qq.chisq(-2*log(as.numeric(as.character(file$LRT_P_Perm))), df=2, x.max=30, main = paste(batches[i], "Base") ,  pvals=T)
		legend("topleft", , signif(GI[3][[1]]),2) 
		out <- gsub(dirname(noKins[i]), pattern = ".*phenos/", replacement = "")
		message(paste(out, "base GI is", GI[3][[1]] ) ) 

		hit <- grep(batches[i], groups$Cohort ) 		
		groups$GenomicInflationBase[hit] <- GI[3][[1]]
		}

		permFile <- paste0(files[i], "/regress1")
		if(file.exists(permFile))
		{
		file <- read.table(permFile , header=T)		
		pvals=pchisq(file$Perm_1,1,lower=F)*0.5
		GI <- qq.chisq(-2*log(as.numeric(as.character(pvals))), df=2, x.max=30, main = paste(batches[i], "Perm") ,  pvals=T)
		legend("topleft", , signif(GI[3][[1]]),2) 
		out <- gsub(dirname(permFile), pattern = ".*phenos//", replacement = "")
		message(paste(out, "permuted GI is", GI[3][[1]] ) ) 

		hit <- grep(batches[i], groups$Cohort ) 		
		groups$GenomicInflationPerm[hit] <- GI[3][[1]]
		}

		techFile <- paste0(files[i], "/regressALL")
		if(file.exists(techFile)) 
		{	
		file <- read.table(techFile , header=T)		
		GI <- qq.chisq(-2*log(as.numeric(as.character(file$LRT_P_Perm))), df=2, x.max=30, main = paste(batches[i], "Tech") ,  pvals=T)
		legend("topleft", , signif(GI[3][[1]]),2) 
		out <- gsub(dirname(techFile), pattern = ".*phenos//", replacement = "")
		message(paste(out, "GI is", GI[3][[1]] ) ) 

		hit <- grep(batches[i], groups$Cohort ) 		
		groups$GenomicInflationTech[hit] <- GI[3][[1]]
		}
	}	

dev.off()



