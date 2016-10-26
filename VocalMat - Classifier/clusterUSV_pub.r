library(WGCNA)
comArgs <- commandArgs(TRUE)

getGSMatrix = function(simbatch,n)
{
		identMat <- matrix(nrow=n,ncol=n)
		rownames(identMat) <- simbatch[1:n,1]
		colnames(identMat) <- simbatch[1:n,1]
		
		count <- 0
		for (col in 1:ncol(identMat))
		{
			count = count+1
			end <- count*ncol(identMat)
			start <- (end-ncol(identMat))+1
			identMat[,col] <- simbatch[start:end,6]
		}
		
		rownames(identMat) <- as.numeric(gsub(".wav","",rownames(identMat)))
		colnames(identMat) <- as.numeric(gsub(".wav","",colnames(identMat)))
		
		return(identMat)
}

clusterTableCreateNoData = function(syntax)
{
	clusters = unique(syntax)
	clusterTable = list()
	
	for (value in clusters)
	{
		tempClust = syntax[syntax==value]
		refs = names(tempClust)
		clusterTable[[value]] = refs
	}
	
	return(clusterTable)
}


	file <- comArgs[1]
	data <- read.csv(file,header=FALSE)
	stat <- apply(data[,c(3:5)],1,prod,na.rm=TRUE)
	data <- cbind(data,stat)
	corMat <- getGSMatrix(data,sqrt(nrow(data)))
	fc <- hclust(as.dist(1-corMat),method="average")
	groups <- cutreeDynamic(fc,minClusterSize=5,distM=as.matrix(1-corMat),deepSplit=1)
	groups <- labels2colors(groups)
	names(groups) <- rownames(corMat)
	mes <- moduleEigengenes(corMat,groups)
	cTable <- clusterTableCreateNoData(groups)
	spl <- strsplit(file,"/")
	maxspl <- length(spl[[1]])
	fileOut <- paste(gsub(spl[[1]][maxspl],"",file),"cluster_workspace.rdata",sep="")
	save(list=ls(),file=fileOut)
    lapply(cTable, write, "clusters.txt", append=TRUE, ncolumns=1000)


