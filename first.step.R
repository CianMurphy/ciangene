library(snpStats)
dir <- "/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_August2014/mainset_August2014_by_chr/"
files <- list.files(dir, pattern ="_snpStats.RData", full.names=T) 
files <- files[order(as.numeric(gsub(gsub(basename(files), pattern ="chr", replacement =""), pattern = "_.*", replacement = "") ) )]

oDir <- "/scratch2/vyp-scratch2/cian/UCLex_August2014/" ; if(!file.exists(oDir)) dir.create(oDir) 
full <- paste0(oDir, "allChr_snpStats") 
annotations.out <- paste0(oDir, "annotations.snpStat")
out <- paste0(full, ".RData") 
a.out <- paste0(annotations.out, ".RData") 

for(i in 1:length(files)){ 
	load(files[i]) ; message(files[i])
	oFile <- paste0(oDir, gsub(basename(files[i]), pattern = ".RData", replacement = ""))
	write.table(rownames(matrix.depth),  paste0(oDir, "variants") , col.names=F, row.names=F, quote=F, sep="\t", append = T) 
	if(i==1) write.SnpMatrix(t(matrix.calls.snpStats), full, col.names=T, row.names=T, quote=F, sep="\t", append=F) 
	if(i>1)  write.SnpMatrix(t(matrix.calls.snpStats), full, col.names=F, row.names=T, quote=F, sep="\t", append=T) 

	if(i==1) write.table(annotations.snpStats, annotations.out, col.names=T, row.names=T, quote=F, sep="\t", append=F) 
	if(i>1)  write.table(annotations.snpStats, annotations.out, col.names=F, row.names=T, quote=F, sep="\t", append=T) 

	pass <- which(annotations.snpStats$FILTER == "PASS")
	write.table(rownames(annotations.snpStats)[pass], paste0(oDir, "clean_variants"), col.names=F , row.names=F, quote=F, sep="\t", append = T)
} 
