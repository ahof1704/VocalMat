comArgs <- commandArgs(TRUE)

#load USV cluster workspace
spl <- strsplit(comArgs[1],"/")
maxspl <- length(spl[[1]])
fileIn <- paste(gsub(spl[[1]][maxspl],"",comArgs[1]),"cluster_workspace.rdata",sep="")
dirIn <- gsub(spl[[1]][maxspl],"",comArgs[1])
load(fileIn)
names(mes[[3]]) <- names(mes[[2]])

comArgs <- commandArgs(TRUE)

#correlate all syllables to cluster eigensyllable
bestSylsOut <- vector()
for(name in names(cTable))
{
	cor.cluster <- vector()
	for(name2 in cTable[[name]])
	{
		cor.cluster <- c(cor.cluster,cor(mes[[1]][,paste("ME",name,sep="")],corMat[name2,]))
	}
	names(cor.cluster) <- cTable[[name]]
	cor.cluster <- sort(cor.cluster,decreasing=TRUE)
	bestSyl <- names(cor.cluster)[1]
	bestSylsOut <- c(bestSylsOut,bestSyl)
}
names(bestSylsOut) <- names(cTable)

	#copy wav files into their own directory for MATLAB to draw into spectrograms during assignment
	#if(file.exists(paste(dirIn,"matlab_wavs",sep="/"))){unlink(paste(dirIn,"matlab_wavs",sep="/"),recursive=TRUE)}
	
	#dir.create(paste(dirIn,"matlab_wavs",sep="/"))
	
	maxSylChar <- nchar(max(as.numeric(rownames(corMat))))
	
	for(cluster in names(cTable))
	{
		#if(length(cTable[[cluster]])>as.numeric(comArgs[4]))
        if(length(cTable[[cluster]])>as.numeric(5))
		{
			if(mes[[3]][paste("AE",cluster,sep="")]>=as.numeric(0.8))
			{
				#get correct filename
				name.assign <- paste("%0",maxSylChar,"s",sep="")
                sylNum <- gsub(" ","0",sprintf(name.assign,as.numeric(bestSylsOut[cluster])))
				name.out <- paste(dirIn,sylNum,".wav",sep="")
	
				#move wav file into spectro folder
				file.copy(from=name.out,to=paste(dirIn,"matlab_wavs/",cluster,".wav",sep=""))
			}
			if(mes[[3]][paste("AE",cluster,sep="")]<as.numeric(0.8))
			{
				if(is.matrix(groups))
				{
					members <- rownames(subset(groups,groups[,1]==cluster))
				}else
				{
					members <- names(subset(groups,groups==cluster))
				}
				
				name.assign <- paste("%0",maxSylChar,"s",sep="")
				for (name in members)
				{
                    sylNum <- gsub(" ","0",sprintf(name.assign,as.numeric(name)))
					name.out <- paste(dirIn,sylNum,".wav",sep="")
					file.copy(from=name.out,to=paste(dirIn,"matlab_wavs/",sylNum,".wav",sep=""))
				}
			}
		}else
		{
			if(is.matrix(groups))
			{
				members <- rownames(subset(groups,groups[,1]==cluster))
			}else
			{
				members <- names(subset(groups,groups==cluster))
			}
			name.assign <- paste("%0",maxSylChar,"s",sep="")
			for (name in members)
			{
                sylNum <- gsub(" ","0",sprintf(name.assign,as.numeric(name)))
				name.out <- paste(dirIn,sylNum,".wav",sep="")
                file.copy(from=name.out,to=paste(dirIn,"matlab_wavs/",sylNum,".wav",sep=""))
			}
		}
		
	}
fileOut <- paste(gsub(spl[[1]][maxspl],"",file),"cluster_workspace.rdata",sep="")
save(list=ls(),file=fileOut)