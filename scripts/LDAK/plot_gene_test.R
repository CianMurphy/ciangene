library(snpStats)

files <- list.files(pattern = "with_kin") 
batches <- gsub(files, pattern = ".*01_", replacement = "")

groups <- read.table("/cluster/project8/vyp/cian/data/UCLex/UCLex_October2014/All_phenotypes/Nb_per_group", header=F ) 
groups$GenomicInflationTech <- 0 
groups$GenomicInflationPerm <- 0 

oFile <- "UCLex_October_big_cohorts_model_comparison.pdf"
pdf(oFile)
par(mfrow=c(2,2), cex.main = 0.6) 

	for(i in 1:length(files)) 
	{
		permFile <- paste0(files[i], "/regress1")
		if(file.exists(permFile))
		{
		file <- read.table(permFile , header=T)		
		pvals=pchisq(file$Perm_1,1,lower=F)*0.5
		GI <- qq.chisq(-2*log(as.numeric(as.character(pvals))), df=2, x.max=30, main = paste(batches[i], "Perm"), pvals=T) ; message(GI[3][[1]])
		hit <- grep(batches[i], groups[,1] ) 		
		groups$GenomicInflationPerm[hit] <- GI[3][[1]]
		}

		techFile <- paste0(files[i], "/regressALL")
		if(file.exists(techFile)) 
		{	
		file <- read.table(techFile , header=T)		
		GI <- qq.chisq(-2*log(as.numeric(as.character(file$LRT_P_Perm))), df=2, x.max=30, main = paste(batches[i], "Tech"), pvals=T); message(GI[3][[1]])
		hit <- grep(batches[i], groups[,1] ) 		
		groups$GenomicInflationTech[hit] <- GI[3][[1]]
		}
	}	

dev.off()
