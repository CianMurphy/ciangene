release <- 'February2015'
fam <- data.frame(read.table(paste0("/scratch2/vyp-scratch2/ciangene/UCLex_", release, "/UCLex_", release, ".fam") , header=F, sep="\t")[,1]) 

names <- as.character(unlist(fam[,1]) ) 

fix <- c("fastq", "B2", "BC", "UCL", "gos", "gg") 
for(i in 1:length(fix)) 
{ 
  if(i==1) 
    { 
      matchy <- fix[i] 
    } 
  else 
    { 
      matchy <- paste0("^", fix[i]) 
    }
  fixB2 <- grepl(matchy , names)  
  names[fixB2] <- paste0(fix[i], "_",  names[fixB2] )
} 

groups <- gsub(names, pattern = "_.*", replacement = "") 
groups.uniq <- unique(gsub(names, pattern = "_.*", replacement = "") )


nb.groups <- length(groups.uniq)

write.table(nb.groups, "nb.groups", col.names=F, quote=F, row.names=F, sep="\t") 
write.table(groups.uniq, "Groups", col.names=F, quote=F, row.names=F, sep="\t") 
write.table(data.frame(table(groups)), "Nb_per_group", col.names=F, row.names=F, quote=F, sep="\t")

phenotypes <- data.frame(matrix (nrow = length(names) , ncol = nb.groups + 2 )) 
phenotypes[,1:2] <- gsub(fam[,1], pattern = " .*", replacement = "")

for(i in 1:nb.groups) 
{ 
	match <- which(groups == groups.uniq[i] ) 
	phenotypes[ , i + 2 ] <- 0 
	phenotypes[match , i + 2 ] <- 1
} 

write.table(phenotypes, "/scratch2/vyp-scratch2/cian/UCLex_August2014/All_phenotypes", col.names=F, row.names=F, quote=F, sep="\t" ) 
