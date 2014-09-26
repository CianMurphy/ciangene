files <- list.files("/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_August2014/mainset_August2014_by_chr/", pattern = "snpStats", full.names=T)
files <- files[order(as.numeric(gsub(gsub(basename(files), pattern ="chr", replacement =""), pattern = "_.*", replacement = "") ) )]
oDir <- "/scratch2/vyp-scratch2/cian/UCLex_August2014/read_depth/"

if(!file.exists(oDir) ) dir.create(oDir) 


oFile <- "Depth_Matrix.sp"

oMap <- paste0(oDir, "Depth_Matrix.map")
oBim <- paste0(oDir, "Depth_Matrix.bim")


for(i in 1:length(files) ) { 
	load(files[i]) ; message(files[i]) 

	short <- gsub(basename(files), pattern = "_.*", replacement ='')[i]
	tmp <-  paste0(oDir, short)
	matrix.depth <- apply(matrix.depth, 2, as.numeric)
	pass <- which(annotations.snpStats$FILTER == "PASS")
	matrix.depth <- matrix.depth[pass,]

	if(i==1) write.table(matrix.depth, file = paste0(oDir, oFile) , col.names=F, row.names=F, quote = F, sep="\t" , append = F)
	if(i>1) write.table(matrix.depth,  file = paste0(oDir, oFile) , col.names=F, row.names=F, quote = F, sep="\t" , append = T)
	
	rownames(matrix.depth) <- colnames(matrix.calls.snpStats)[pass]
	map <- data.frame(matrix(nrow=nrow(matrix.depth), ncol = 4) ) 
	map[,1] <-  gsub(rownames(matrix.depth) ,pattern =  "_.*",  replacement = "" )
	map[,4] <-  gsub(sub(rownames(matrix.depth) ,pattern =  "[0-9]{1,2}_",  replacement = "" ), pattern = "_.*", replacement = "")
	map[,4] <-  gsub(sub(rownames(matrix.depth) ,pattern =  "._",  replacement = "" ), pattern = "_.*", replacement = "")
	map[,2] <- rownames(matrix.depth)
	map[,3] <- 0 

	map[,1] <- gsub(map[,1], pattern = "X", replacement = "23")
	map[,1] <- gsub(map[,1], pattern = "Y", replacement = "24")
	map[,4] <- gsub(map[,4], pattern = "X", replacement = "23")
	map[,4] <- gsub(map[,4], pattern = "Y", replacement = "24")

	map[,1] <- as.numeric(map[,1]) 
	map[,4] <- as.numeric(map[,4]) 
	if(i==1) write.table(map, oMap, col.names=F, row.names=F, quote=F, sep="\t", append=F) 
	if(i>1) write.table(map, oMap, col.names=F, row.names=F, quote=F, sep="\t", append=T) 
	if(i==1) write.table(data.frame(cbind(map, "A", "B") ) , oBim, col.names=F, row.names=F, quote=F, sep="\t", append=F) 
	if(i>1) write.table(data.frame(cbind(map, "A", "B") ) , oBim, col.names=F, row.names=F, quote=F, sep="\t", append=T) 
} 




fam <- data.frame(matrix(nrow=ncol(matrix.depth), ncol = 6)  ) 
fam[,1] <- colnames(matrix.depth)
fam[,2] <- colnames(matrix.depth)
fam[,3] <- 0 
fam[,4] <- 0 
fam[,3] <- 0 
fam[,3] <- 0 
write.table(fam, paste0(oDir, "Depth_Matrix.fam") , col.names=F, row.names=F, quote=F, sep="\t") 

bim <- read.table(oBim, header=F, sep="\t") 
bim <- bim[with(bim, order(V1, V4)), ]
write.table(bim, oBim, col.names=F, row.names=F, quote=F ,sep="\t") 
