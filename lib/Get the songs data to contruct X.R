################################################### contrust X ################################################
library(rhdf5)
library(pracma)
library(cluster) 
library(fpc)
library(flexclust)
##### import data 
setwd("~/Desktop/Project4_data/data")
files = dir(".", recursive=TRUE, full.names=TRUE)

## find out the min n 
length = vector()
for (i in 1:length(files)){
  dfanal = h5read(files[i], "/analysis")
  length[i] = length(dfanal$segments_loudness_max)
}
length[which.min(length)]

#### clean up different features and do cluster analysis for different features  
segments_loudness_maxs = c()
segments_loudness_max_times = c()
segments_pitchess_1 = c()
segments_pitchess_2 = c()
segments_pitchess_3 = c()
segments_pitchess_4 = c()
segments_pitchess_5 = c()
segments_pitchess_6 = c()
segments_pitchess_7 = c()
segments_pitchess_8 = c()
segments_pitchess_9 = c()
segments_pitchess_10 = c()
segments_pitchess_11 = c()
segments_pitchess_12 = c()
segments_timbres_1 = c()
segments_timbres_2 = c()
segments_timbres_3 = c()
segments_timbres_4 = c()
segments_timbres_5 = c()
segments_timbres_6 = c()
segments_timbres_7 = c()
segments_timbres_8 = c()
segments_timbres_9 = c()
segments_timbres_10 = c()
segments_timbres_11 = c()
segments_timbres_12 = c()
segments_timbres = list(segments_timbres_1,segments_timbres_2,segments_timbres_3,segments_timbres_4,
                        segments_timbres_5,segments_timbres_6,segments_timbres_7,segments_timbres_8,
                        segments_timbres_9,segments_timbres_10,segments_timbres_11,segments_timbres_12)
segments_pitchess = list(segments_pitchess_1,segments_pitchess_2,segments_pitchess_3,segments_pitchess_4,
                         segments_pitchess_5,segments_pitchess_6,segments_pitchess_7,segments_pitchess_8,
                         segments_pitchess_9,segments_pitchess_10,segments_pitchess_11,segments_pitchess_12)

for (file in files){
  dfanal = h5read(file, "/analysis")
  n = length(dfanal$segments_loudness_max)
  if (n<20){
    segments_loudness_max = rep(dfanal$segments_loudness_max,times = 5,len = 20)
    segments_loudness_max_time = rep(dfanal$segments_loudness_max_time[1:8],times = 5,len = 20)
    segments_pitches = repmat(dfanal$segments_pitches, n = 1, m = 5)[,1:20]
    segments_timbre = repmat(dfanal$segments_timbre, n = 1, m = 5)[,1:20]
  } else {
    save = floor((n-1)/19)*c(0:19)+1
    segments_loudness_max = dfanal$segments_loudness_max[save]
    segments_loudness_max_time = dfanal$segments_loudness_max_time[save]
    segments_pitches = dfanal$segments_pitches[,save]
    segments_timbre = dfanal$segments_timbre[,save]
  }
  segments_loudness_maxs = rbind(segments_loudness_maxs,segments_loudness_max)
  segments_loudness_max_times = rbind(segments_loudness_max_times,segments_loudness_max_time)
  for (i in 1:12){
    segments_pitchess[[i]] = rbind(segments_pitchess[[i]],segments_pitches[i,])
    segments_timbres[[i]] = rbind(segments_timbres[[i]],segments_timbre[i,])
  }
}



rownames(segments_loudness_maxs) = files
rownames(segments_loudness_max_times) = files
for (i in 1:12) {
  rownames(segments_pitchess[[i]]) = files
  rownames(segments_timbres[[i]]) = files
}

# Check for the results 
dim(segments_timbres[[4]])
dim(segments_timbres[[12]])
segments_timbres[[4]][1:10,1:20]
segments_timbres[[12]][1:10,1:20]


###### Cluster analysis ---- Kmeans 
### define the independent variables 
indep_x = data.frame(row.names = files)

### K-means 
## first feature 
loudness_maxs_clu = scale(segments_loudness_maxs)
wss = (nrow(loudness_maxs_clu)-1)*sum(apply(loudness_maxs_clu,2,var))
for (i in 2:15) {
  wss[i] = sum(kmeans(loudness_maxs_clu, centers=i)$withinss)
}
plot(1:15, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

set.seed(2016)
cl_1 = cclust(loudness_maxs_clu, k=14, dist = "euclidean", method = "kmeans")
pred_train_1 =  predict(cl_1)
indep_x$loudness_maxs = pred_train_1

## second feature 
loudness_max_times_clu = scale(segments_loudness_max_times)
loudness_max_times_clu[is.na(loudness_max_times_clu)] = 0.02
# Determine number of clusters
wss = (nrow(loudness_max_times_clu)-1)*sum(apply(loudness_max_times_clu,2,var))
for (i in 2:30) {
  wss[i] = sum(kmeans(loudness_max_times_clu, centers=i)$withinss)
}
plot(1:30, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

set.seed(2016)
cl_2 = cclust(loudness_max_times_clu, k=25, dist = "euclidean", method = "kmeans")
pred_train_2 = predict(cl_2)
indep_x$loudness_max_times = pred_train_2


## third and forth features 
cl_3 = list()
for (i in 1:12){
  segments_pitchess_clu = scale(segments_pitchess[[i]])
  segments_pitchess_clu[is.na(segments_pitchess_clu)] = 0.02
  set.seed(2016)
  cl.1 = cclust(segments_pitchess_clu, k=10, dist = "euclidean", method = "kmeans")
  pred_train.1 = predict(cl.1)
  indep_x[,i+2] = pred_train.1
  names(indep_x)[i+2] = paste0("segments_pitches.",i)
  cl_3[[i]] = cl.1
}

cl_4 = list()
for (i in 1:12){
  segments_timbres_clu = scale(segments_timbres[[i]])
  segments_timbres_clu[is.na(segments_timbres_clu)] = 0.02
  set.seed(2016)
  cl.2 = cclust(segments_timbres_clu, k=10, dist = "euclidean", method = "kmeans")
  pred_train.2 = predict(cl.2)
  indep_x[,i+14] = pred_train.2
  names(indep_x)[i+14] = paste0("segments_timbre",i)
  cl_4[[i]] = cl.2
}

head(indep_x)
dim(indep_x)
rownames(indep_x) = substring(rownames(indep_x),9,26)
X = indep_x

#### Form up to X 
for (i in 1:26){
  X[[i]] = as.factor(X[[i]])
}
