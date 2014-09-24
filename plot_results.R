library(snpStats)

dirs <- list.dirs()
oFile <- "gene_tests_qqplots.pdf"
pdf(oFile)
par(mfrow=c(2,2), ps = 6, cex = 1, cex.main = 1)

for(i in 1:length(dirs)) { 
target <- paste0(dirs[i], "/regressALL")
if(file.exists(target)) { 
	file <- read.table(target , header=T, sep=" ") 
	qq.chisq( -2*log(file$LRT_P  ) , df = 2, x.max = 30, pvals = TRUE, main = paste(dirs[i], "LRT"  )  )
	qq.chisq( -2*log(file$Score_P) , df = 2, x.max = 30, pvals = TRUE, main = paste(dirs[i], "Score")  )
	} 
}
dev.off()

