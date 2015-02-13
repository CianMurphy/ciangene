library(snpStats)


getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}

release <- 'August2014'

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]

#######################



dir <- paste0("/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_", release , "/mainset_", release, "_by_chr/")
files <- list.files(dir, pattern ="_snpStats.RData", full.names=T) 
files <- files[order(as.numeric(gsub(gsub(basename(files), pattern ="chr", replacement =""), pattern = "_.*", replacement = "") ) )]

oDir <- paste0(rootODir, "/UCLex_", release)
if(!file.exists(oDir)) dir.create(oDir)

full <- paste0(oDir, "/allChr_snpStats") 
annotations.out <- paste0(oDir, "/annotations.snpStat")
out <- paste0(full, ".RData") 
a.out <- paste0(annotations.out, ".RData") 

for(i in 1:length(files)){ 
  load(files[i])
  message(files[i])
  
  oFile <- paste0(oDir, "/", gsub(basename(files[i]), pattern = ".RData", replacement = ""))
  write.table(rownames(matrix.depth),  paste0(oDir, "/variants") , col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t", append = TRUE) 
  if(i==1) write.SnpMatrix(t(matrix.calls.snpStats), full, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t", append=FALSE)   ##this is where it becomes numbers
  if(i>1)  write.SnpMatrix(t(matrix.calls.snpStats), full, col.names=FALSE, row.names=TRUE, quote=FALSE, sep="\t", append=TRUE) 
  
  if(i==1) write.table(annotations.snpStats, annotations.out, col.names=TRUE, row.names=TRUE, quote=FALSE, sep="\t", append=FALSE) 
  if(i>1)  write.table(annotations.snpStats, annotations.out, col.names=FALSE, row.names=TRUE, quote=FALSE, sep="\t", append=TRUE) 
  
  pass <- which(annotations.snpStats$FILTER == "PASS")
  write.table(rownames(annotations.snpStats)[pass], paste0(oDir, "/clean_variants"), col.names=FALSE , row.names=FALSE, quote=FALSE, sep="\t", append = TRUE)
} 
