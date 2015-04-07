source("qqplot.R") ## modified snpStats qq.chisq function to return obsvd and expctd values. 

labelQQplot <- function(pval.labels, qqplotOut ,pvals.raw, nb.pvals=5, col=col) 
{
	dat <- data.frame(pval.labels, pvals.raw) 
	qqplotOut<-qqplotOut[-c(1:3)]
	obsvd <- qqplotOut[1: (length(qqplotOut)/2)]
	expctd<- qqplotOut[((length(qqplotOut)/2)+1): length(qqplotOut)]
	plotty <- data.frame(obsvd,expctd) 
	tra <- plotty[order(-plotty$expctd),]
	plot.data <- data.frame(labels=pval.labels,pvals=pvals.raw) 
	plot.data<-plot.data[order(plot.data$pvals),]
	plot.vals <- data.frame(plot.data,tra)[1:nb.pvals,]
	upper.labs <- plot.vals[seq(from=1,by=2, to=nrow(plot.vals)),]
	lower.labs <- plot.vals[seq(from=2,by=2, to=nrow(plot.vals)),]
	
	x.offset=1
	y.offset=0
	text(upper.labs$expctd-x.offset,upper.labs$obsvd+y.offset, labels=upper.labs$labels, col = col, adj=c(1,0.5) ) 
	segments(upper.labs$expctd, upper.labs$obsvd, upper.labs$expctd-x.offset, upper.labs$obsvd+y.offset, col =col) 

	text(lower.labs$expctd+x.offset,lower.labs$obsvd-y.offset, labels=lower.labs$labels, col = col, adj=c(0,0.5) ) 
	segments(lower.labs$expctd, lower.labs$obsvd, lower.labs$expctd+x.offset, lower.labs$obsvd-y.offset, col =col) 
}



#file <- read.table("regressALL", header=T) 
#tst <- qq.chisq(-2*log(file$LRT_P_Perm), df=2, x.max=30)
#labelQQplot(file$Gene_name, tst, file$LRT_P_Perm) 
