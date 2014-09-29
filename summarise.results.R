oDir <- "Results"
if(!file.exists(oDir)) dir.create(oDir)

techs <- list.files(, pattern = "Tech_with_kin", full.names=T)
short <- gsub(techs, pattern = ".*_kin", replacement="")
oFiles <- gsub(gsub(short, pattern = ".*pheno_", replacement = ""), pattern = "_.*", replacement = "") 


for(i in 1:length(techs)){
	target <- paste0(techs[i], "/regressALL")
	if(file.exists(target)) { 
	tech <- read.table(target, header=T, sep=" ")
	base.dir <- paste0("no_kin", short[i])
	base <- read.table(paste0(base.dir, "/regressALL"), header=T, sep=" ", stringsAsFactors=F)
	base.small <- data.frame(cbind(base$Gene_name, base$LRT_P, base$Score_P)) 
	names(base.small) <- c("Gene_name", "LRT_P.base", "Score_P.base")
	merged <- merge(tech, base.small)
	merged$ScorePvalue.diff <- as.numeric(as.character(merged$Score_P.base) ) - merged$Score_P 
	merged <- merged[order(merged$Score_Pvalue.diff), ] 
	write.table(merged, paste0(oDir, "/", oFiles[i]), col.names=T, row.names=F, quote=F, sep="\t")
	} 
}






##### old
python <- FALSE
if(python) {

library(rPython)

python.assign("dict", tech) 
python.assign("base", base) 

python.exec('import pandas as pd') 

python.exec('py_df = pd.DataFrame(dict)')
python.exec('base_py_df = pd.DataFrame(base)') 

python.exec('py_df.join(base_py_df') 


} 
