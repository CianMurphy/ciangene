library(snpStats)

dirs <- list.dirs(, pattern = "_kin_m")

### plot by cohort not by state: 
oFile <- "sorted_gene_tests_qqplots.pdf"
pdf(oFile)
par(mfrow=c(2,2), ps = 6, cex = 1, cex.main = 1)

cohort <- gsub(gsub(dirs, pattern = ".*pheno_", replacement ="") , pattern ="_.*", replacement = "") 
cohort.uniq <- unique(cohort)

modes <- c( 
"no_kin_maf_0.00001_pheno_" , 
"perm_no_kin_maf_0.00001_pheno_" , 
"Depth_perm_with_kin_maf_0.00001_pheno_" , 
"Depth_with_kin_maf_0.00001_pheno_" , 
"Tech_with_kin_maf_0.00001_pheno_" , 
"Tech_perm_with_kin_maf_0.00001_pheno_" , 
"res"
) 

for(i in 1:length(cohort.uniq)) { 
	for(t in 1:length(modes)) { 

		if(t < length(modes)) 
		{ 
			iFile <- paste0( modes[t], cohort.uniq[i], "_missingness_0.9/regressALL") 
			message(iFile) 

			if(file.exists(iFile)) { 
			file <- read.table(iFile , header=T, sep=" ") 
			qq.chisq( -2*log(file$LRT_P  ) , df = 2, x.max = 30, pvals = TRUE, main = paste( paste0( modes[t], cohort.uniq[i]), "LRT"  )  )
			qq.chisq( -2*log(file$Score_P) , df = 2, x.max = 30, pvals = TRUE, main = paste( paste0( modes[t], cohort.uniq[i]), "Score")  )
			} 
		} # if(t < length(modes)) { 


		if(t == length(modes)) 
		{ 
			iFile <- paste0( "Tech_with_kin_maf_0.00001_pheno_" , cohort.uniq[i], "_missingness_0.9_res/regressALL")
			message(iFile)

			if(file.exists(iFile)) { 
			file <- read.table(iFile , header=T, sep=" ") 
			qq.chisq( -2*log(file$LRT_P  ) , df = 2, x.max = 30, pvals = TRUE, main = paste( paste0( "Tech Depth ", cohort.uniq[i]), "LRT"  )  )
			qq.chisq( -2*log(file$Score_P) , df = 2, x.max = 30, pvals = TRUE, main = paste( paste0( "Tech Depth ", cohort.uniq[i]), "Score")  )
			} 	

			iFile <- paste0( "Tech_perm_with_kin_maf_0.00001_pheno_" , cohort.uniq[i], "_missingness_0.9_res/regressALL")
			message(iFile)
	
			if(file.exists(iFile)) { 
			file <- read.table(iFile , header=T, sep=" ") 
			qq.chisq( -2*log(file$LRT_P  ) , df = 2, x.max = 30, pvals = TRUE, main = paste( paste0( "Tech Depth perm", cohort.uniq[i]), "LRT"  )  )
			qq.chisq( -2*log(file$Score_P) , df = 2, x.max = 30, pvals = TRUE, main = paste( paste0( "Tech Depth perm", cohort.uniq[i]), "Score")  )
			} 	
		 } # if(t == length(modes)) 
	} # for(t in 1:length(modes)) { 
} # for(i in 1:length(cohort.uniq)) { 

dev.off()





