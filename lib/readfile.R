setwd("C:/Users/liran/Desktop/Proj 4 Data/Project4_data/data")
files <- dir(".", recursive=TRUE, full.names=TRUE)

###################
# Installing rhdf5#
###################
source("http://bioconductor.org/biocLite.R")
biocLite("rhdf5")
library(rhdf5)

###########################
# Extracting all songs data
ptm <- proc.time()
a_songs<-c()



for (file in files){
  dfanal <- h5read(file, "/analysis")
  a_song <-dfanal$songs
  
  a_songs<-rbind(a_songs,a_song)
}
proc.time() - ptm


songs <- cbind(files,a_songs)
save(songs,file="songs.RData")