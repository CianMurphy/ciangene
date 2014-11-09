library(snpStats)

timeStamp <- "UCLex_August2014"

files <-  as.character(unlist(do.call("rbind", lapply(list.dirs(),  list.files, pattern = "Out", full.names=T))))

clean <- read.table(paste0("/scratch2/vyp-scratch2/cian/", timeStamp, "/clean_variants") , header=F, sep="\t")

maf	<- read.table("/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/Gene_based_tests/Good_runs/snp.summary", header=T, sep="\t")
mafs <- c(0.1, 0.01, 0.001, 0.0001, 0.00001, 0)

oFile <- paste0(timeStamp, "_single_variant_qqplot.pdf")
oDir <- "Results"



if(!file.exists(oDir)) dir.create(oDir)

pdf(oFile)
par(mfrow=c(3,2))
lapply(files, function(file.var) 
{ 
	file <- read.table(file.var, header=T, sep="\t", stringsAsFactors=F)
	file.small <- file[file$SNP %in% clean[,1], ]

	lapply(rev(mafs), function(filt)
	{
		file.small.maf <- file.small[file.small$SNP %in% maf$rownames.annotations.snpStats.[maf$MAF >= filt], ]
		write.table(file.small.maf, file = paste0(oDir, "/", basename(file.var), "_", filt) , col.names=T, row.names=F, quote=F, sep="\t") 
		qq.chisq( -2*log(as.numeric(file.small.maf$Pvalue))  , df=2, x.max = 30, pvals=T, main = paste(basename(file.var), filt, nrow(file.small.maf))  )
	}
	)
}
)
dev.off() 



### subset plot
library(snpStats)

pdf("Single_variant_subset.pdf") 
par(mfrow=c(2,2)) 
file <- read.table("Results/Hardcastle_Out_no_kin_0", header=T, sep="\t" )
qq.chisq( -2*log(as.numeric(file$Pvalue))  , df=2, x.max = 30, pvals=T, main = "No Kinship, all Variants"  )

file <- read.table("Results/Hardcastle_Out_0", header=T, sep="\t" )
qq.chisq( -2*log(as.numeric(file$Pvalue))  , df=2, x.max = 30, pvals=T, main = "Technical Kinship, all Variants"  )

file <- read.table("Results/Hardcastle_Out_no_kin_0.1", header=T, sep="\t" )
qq.chisq( -2*log(as.numeric(file$Pvalue))  , df=2, x.max = 30, pvals=T, main = "No Kinship, MAF 0.1"  )

file <- read.table("Results/Hardcastle_Out_0.1", header=T, sep="\t" )
qq.chisq( -2*log(as.numeric(file$Pvalue))  , df=2, x.max = 30, pvals=T, main = "Technical Kinship, MAF 0.1"  )

dev.off() 



