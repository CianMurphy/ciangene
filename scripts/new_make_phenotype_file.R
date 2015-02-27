comp <- "mbp"
if(comp == "mbp") options(width=170)

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

iFile <- paste0("/cluster/project8/vyp/exome_sequencing_multisamples/mainset/GATK/mainset_", release, "/mainset_", release, "_snpStats/chr21_snpStats.RData")
load(iFile)


oDir <- "/scratch2/vyp-scratch2/cian/UCLex_February2015/"

groups <- gsub(colnames(matrix.depth), pattern = "_.*",replacement = "")
groups.unique <- unique(groups)

# Tring to group samples by cohort correctly. Default method is to use string before first underscore in their name, but that doesn't work for all samples, 
# so to try group correctly (eg to prevent ALevine from being treated as a separate phenotype from Levine, use fixPhenoGroupings )
use.fixPhenoGroupings <- TRUE

if(use.fixPhenoGroupings)
{
	cohorts.to.fix <- c("Levine", "B2", "BC", "UCL", "UCLG", "Syrris", "gosgeneBGI")
	
	nb.original.groups <- length(groups.unique)

	fixPhenoGroupings <- function(cohorts, inGroups)
	{

		for(i in 1:length(cohorts.to.fix))
		{
			hit <- grep(cohorts.to.fix[i], inGroups)
			inGroups[hit] <- cohorts.to.fix[i]
		}

		groups.unique <- unique(inGroups)
		nb.new.groups <- length(groups.unique)

		out <- paste( nb.original.groups - nb.new.groups , "samples have been merged into other cohorts" )
		message(out)

	return(inGroups)
	} # fixPhenoGroupings 

	groups <- fixPhenoGroupings(cohorts.to.fix, groups)
	groups.unique <- unique(groups)


} ### use.fixPhenoGroupings 

nb.groups <- length(unique(groups))

## now make phenotype file 
pheno <- data.frame(matrix(nrow = ncol(matrix.depth), ncol = nb.groups+2))
colnames(pheno) <- c("SampleID1", "SampleID2", groups.unique)
pheno[,1:2] <- colnames(matrix.depth)

for(i in 1:nb.groups)
{
	pheno[, i + 2] <- 1 
	hits <- grep(groups.unique[i], groups )
	pheno[hits,i+2] <- 2
}


## remove pheno for extCtrls
extCtrls <- read.table(paste0(oDir, "ext_ctrl_samples"), header=F) ## made in first.step.R
ex.ctrl.pheno <- pheno[,1] %in% unlist(extCtrls) 
pheno[ex.ctrl.pheno,3:ncol(pheno)] <- '-9'
write.table(pheno, file = paste0(oDir, "Phenotypes"), col.names=F, row.names=F, quote=F, sep="\t") 
## summarise case cohort breakdowns
cohort.summary <- data.frame(do.call(rbind, lapply(pheno[,3:ncol(pheno)], table) )) 
cohort.summary$Cohort <- rownames(cohort.summary) 
colnames(cohort.summary) <- c("Nb.Ctrls", "Nb.cases", "Nb.ext.Ctrls", "Cohort") 
write.table(data.frame(pheno[,1], groups ), paste0(oDir, "Sample.cohort"),  col.names=F, row.names=F, quote=F, sep="\t") 
write.table(cohort.summary, file = paste0(oDir, "cohort.summary"), col.names=T, row.names=F, quote=F, sep="\t") 


