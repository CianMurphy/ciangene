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

#######################################


oDir <- paste0(rootODir, "/UCLex_", release, "/")
oDir <- "/scratch2/vyp-scratch2/cian/UCLex_February2015/" # temp, until integrated into pipeline

extCtrl.var <- read.table( paste0(oDir, "Ext_ctrl_variant_summary") , header=T) 

## some parameters
missingness.threshold <- .9
min.maf <- 0
max.maf <- 0.1 

clean.variants <- subset(extCtrl.var, extCtrl.var$Call.rate >= missingness.threshold) 
percent.removed <- paste0("(", round(( nrow(extCtrl.var) - nrow(clean.variants)) / nrow(extCtrl.var)*100), "%)") 
message(paste(nrow(extCtrl.var) - nrow(clean.variants) , percent.removed, "variants are removed because of call rate") ) 
write.table(clean.variants[,1], file = paste0(oDir, "Clean_variants"), col.names=F, row.names=F, quote=F, sep="\t") 

anno <- read.table(file = paste0(oDir, "annotations.snpStat"), header=T) 
func <-  c("nonsynonymous SNV", "stopgain SNV", "nonframeshift insertion", "nonframeshift deletion", "frameshift deletion", "frameshift substitution", "frameshift insertion",  "nonframeshift substitution", "stoploss SNV")
lof <-  c("frameshift deletion", "frameshift substitution", "frameshift insertion",  "stoploss SNV")
funky <- annotations$clean.signature[annotations$ExonicFunc %in% unlist(func)) ] 
rare <- subset(annotations$clean.signature, annotations$ESP6500si_ALL >= min.maf & annotations$ESP6500si_ALL <= max.maf & annotations$X1000g2012apr_ALL >= min.maf & annotations$X1000g2012apr_ALL <= max.maf ) 
funky.rare <- funky %in% rare
clean.variants.rare <- subset(extCtrl.var[,1] , extCtrl.var$Call.rate >= missingness.threshold & extCtrl.var$MAF >= min.maf & extCtrl.var$MAF >= max.maf) 

clean.funky <- clean.variants.rare %in% funky.rare
write.table(clean.funky, file = paste0(oDir, "Clean_variants_Func"), col.names=F, row.names=F, quote=F, sep="\t") 
