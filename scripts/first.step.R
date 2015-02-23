library(snpStats)


getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'February2015'
percent.ext.ctrls <- .10

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]

#######################

dir <- paste0("/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_", release , "/mainset_", release, "_snpStats/")
files <- list.files(dir, pattern ="_snpStats.RData", full.names=T) 
files <- files[order(as.numeric(gsub(gsub(basename(files), pattern ="chr", replacement =""), pattern = "_.*", replacement = "") ) )]

print(files)

oDir <- paste0(rootODir, "/UCLex_", release)
if(!file.exists(oDir)) dir.create(oDir)

full <- paste0(oDir, "/allChr_snpStats.sp") ## added '.sp' suffix
annotations.out <- paste0(oDir, "/annotations.snpStat")
out <- paste0(full, ".RData") 
a.out <- paste0(annotations.out, ".RData") 

oMap <- paste0(oDir, "/UCLex_", release, ".map")
oBim <- paste0(oDir, "/UCLex_", release, ".bim")


for(i in 1:length(files)){
  message("Now loading file ", files[i])
  load(files[i])
  message(files[i])

  # Extract clean variants. 
  matrix.calls.snpStats <- matrix.calls.snpStats[,which(annotations.snpStats$FILTER == "PASS")]
  annotations.snpStats <- subset(annotations.snpStats, annotations.snpStats$FILTER == "PASS")

	if(i==1) # ext.ctrls
	{ 
	samples <- rownames(matrix.calls.snpStats)
	ext.ctrls <- sample(length(samples), length(samples) * percent.ext.ctrls) 
	}
	ext.samples <- matrix.calls.snpStats[ext.ctrls ,]
	ext.samples.sum <- col.summary(ext.samples) 
	ext.samples.names <- data.frame(rownames(ext.samples) , row.summary(ext.samples) ) 

	if(i==1) write.table(ext.samples.sum, file = paste0(oDir, "_ext_ctrl_variant_summamy") , col.names=T, row.names=F, quote=F, sep="\t", append=F) 
	if(i==1) write.table(ext.samples.names, file = paste0(oDir, "_ext_ctrl_sample_summamy") , col.names=T, row.names=F, quote=F, sep="\t", append=F) 
	
	if(i==1) write.table(ext.samples.sum, file = paste0(oDir, "_ext_ctrl_variant_summamy") , col.names=F, row.names=F, quote=F, sep="\t", append=T) 
	if(i==1) write.table(ext.samples.names, file = paste0(oDir, "_ext_ctrl_sample_summamy") , col.names=F, row.names=F, quote=F, sep="\t", append=T) 


  oFile <- paste0(oDir, "/", gsub(basename(files[i]), pattern = ".RData", replacement = ""))
  #write.table(rownames(matrix.depth),  paste0(oDir, "/variants") , col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append = TRUE) 
  if(i==1) write.SnpMatrix(t(matrix.calls.snpStats), full, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append=FALSE)   ##this is where it becomes numbers
  if(i>1)  write.SnpMatrix(t(matrix.calls.snpStats), full, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append=TRUE) 
  
  if(i==1) write.table(annotations.snpStats, annotations.out, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t", append=FALSE) 
  if(i>1)  write.table(annotations.snpStats, annotations.out, col.names=FALSE, row.names=TRUE, quote=FALSE, sep="\t", append=TRUE) 
  
  #pass <- which(annotations.snpStats$FILTER == "PASS")
  #write.table(rownames(annotations.snpStats)[pass], paste0(oDir, "/clean_variants"), col.names=FALSE , row.names=FALSE, quote=FALSE, sep="\t", append = TRUE)

  matrix.depth <- matrix.depth[which(annotations.snpStats$FILTER == "PASS"),]
  # Make map file 
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
  if(i==1) write.table(map, oMap, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append=FALSE) 
  if(i>1) write.table(map, oMap, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append=TRUE) 
  if(i==1) write.table(data.frame(cbind(map, "A", "B") ) , oBim, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append=FALSE) 
  if(i>1) write.table(data.frame(cbind(map, "A", "B") ) , oBim, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append=TRUE) 


} 

## Make fam file. 
fam <- data.frame(matrix(nrow=ncol(matrix.depth), ncol = 6)  ) 
fam[,1] <- colnames(matrix.depth)
fam[,2] <- colnames(matrix.depth)
fam[,3] <- 0 
fam[,4] <- 0 
fam[,3] <- 0 
fam[,3] <- 0 
write.table(fam, paste0(oDir, "/UCLex_", release, ".fam") , col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t") 

bim <- read.table(oBim, header=FALSE, sep="\t") 
bim <- bim[with(bim, order(V1, V4)), ]
write.table(bim, oBim, col.names=FALSE, row.names=FALSE, quote=FALSE ,sep="\t") 





