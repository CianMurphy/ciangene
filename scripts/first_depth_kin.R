library(snpStats)


getArgs <- function() {
  myargs.list <- strsplit(grep("=",gsub("--","",commandArgs()),value=TRUE),"=")
  myargs <- lapply(myargs.list,function(x) x[2] )
  names(myargs) <- lapply(myargs.list,function(x) x[1])
  return (myargs)
}
release <- 'June2015'
rootODir<-'/scratch2/vyp-scratch2/cian'

myArgs <- getArgs()

if ('rootODir' %in% names(myArgs))  rootODir <- myArgs[[ "rootODir" ]]
if ('release' %in% names(myArgs))  release <- myArgs[[ "release" ]]


########################################

files <- list.files(paste0("/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_", release,"/mainset_",release,"_snpStats"), pattern = "snpStats", full.names=TRUE)
files <- files[order(as.numeric(gsub(gsub(basename(files), pattern ="chr", replacement =""), pattern = "_.*", replacement = "") ) )]

readDepthDir <- paste0(rootODir, "/UCLex_", release, "/read_depth/")
if(!file.exists(readDepthDir) ) dir.create(readDepthDir) 


oFile <- "Depth_Matrix.sp"

oMap <- paste0(oDir, "/Depth_Matrix.map")
oBim <- paste0(oDir, "/Depth_Matrix.bim")


for(i in 1:length(files) ) { 
  load(files[i]) ; message(files[i]) 
  
  short <- gsub(basename(files), pattern = "_.*", replacement ='')[i]
  tmp <-  paste0(oDir, "/", short)
  matrix.depth <- apply(matrix.depth, 2, as.numeric)
 # matrix.depth<-as.numeric(matrix.depth)
  pass <- which(annotations.snpStats$FILTER == "PASS")
  matrix.depth <- matrix.depth[pass,]
  
matrix.depth <- apply(matrix.depth, 2, as.numeric)
if(i==1) write.table(matrix.depth, file = paste0(oDir, "/", oFile) , col.names=FALSE, row.names=FALSE, quote = FALSE, sep="\t" , append = FALSE)
if(i>1) write.table(matrix.depth,  file = paste0(oDir, "/", oFile) , col.names=FALSE, row.names=FALSE, quote = FALSE, sep="\t" , append = TRUE)
  
  rownames(matrix.depth) <- colnames(matrix.calls.snpStats)[pass]

} 



