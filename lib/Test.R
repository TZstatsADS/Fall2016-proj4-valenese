library(rhdf5)
library(pracma)
library(cluster) 
library(fpc)
library(flexclust)
############################### Test functions ################################## 
#### clean up different features and do cluster analysis for different features  
## build up the function for import data and convert it into cluster 
test_X = function(testfiles,TrainFunc1,TrainFunc2,TrainFunc3,TrainFunc4){
  te_segments_loudness_maxs = c()
  te_segments_loudness_max_times = c()
  te_segments_pitchess_1 = c()
  te_segments_pitchess_2 = c()
  te_segments_pitchess_3 = c()
  te_segments_pitchess_4 = c()
  te_segments_pitchess_5 = c()
  te_segments_pitchess_6 = c()
  te_segments_pitchess_7 = c()
  te_segments_pitchess_8 = c()
  te_segments_pitchess_9 = c()
  te_segments_pitchess_10 = c()
  te_segments_pitchess_11 = c()
  te_segments_pitchess_12 = c()
  te_segments_timbres_1 = c()
  te_segments_timbres_2 = c()
  te_segments_timbres_3 = c()
  te_segments_timbres_4 = c()
  te_segments_timbres_5 = c()
  te_segments_timbres_6 = c()
  te_segments_timbres_7 = c()
  te_segments_timbres_8 = c()
  te_segments_timbres_9 = c()
  te_segments_timbres_10 = c()
  te_segments_timbres_11 = c()
  te_segments_timbres_12 = c()
  te_segments_timbres = list(te_segments_timbres_1,te_segments_timbres_2,te_segments_timbres_3,te_segments_timbres_4,
                             te_segments_timbres_5,te_segments_timbres_6,te_segments_timbres_7,te_segments_timbres_8,
                             te_segments_timbres_9,te_segments_timbres_10,te_segments_timbres_11,te_segments_timbres_12)
  te_segments_pitchess = list(te_segments_pitchess_1,te_segments_pitchess_2,te_segments_pitchess_3,te_segments_pitchess_4,
                              te_segments_pitchess_5,te_segments_pitchess_6,te_segments_pitchess_7,te_segments_pitchess_8,
                              te_segments_pitchess_9,te_segments_pitchess_10,te_segments_pitchess_11,te_segments_pitchess_12)
  
  for (file in testfiles){
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
    te_segments_loudness_maxs = rbind(te_segments_loudness_maxs,segments_loudness_max)
    te_segments_loudness_max_times = rbind(te_segments_loudness_max_times,segments_loudness_max_time)
    for (i in 1:12){
      te_segments_pitchess[[i]] = rbind(te_segments_pitchess[[i]],segments_pitches[i,])
      te_segments_timbres[[i]] = rbind(te_segments_timbres[[i]],segments_timbre[i,])
    }
  }
  
  rownames(te_segments_loudness_maxs) = testfiles
  rownames(te_segments_loudness_max_times) = testfiles
  for (i in 1:12){
    rownames(te_segments_pitchess[[i]]) = testfiles
    rownames(te_segments_timbres[[i]]) = testfiles
  }
  
  ###### Cluster analysis ---- Kmeans 
  ### define the independent variables 
  te_indep_x = data.frame(row.names = testfiles)
  
  ### K-means 
  ## first feature 
  te_loudness_maxs_clu = scale(te_segments_loudness_maxs)
  pred_test1 = predict(TrainFunc1,newdata = te_loudness_maxs_clu)
  te_indep_x$loudness_maxs = pred_test1
  
  ## second feature 
  te_loudness_max_times_clu = scale(te_segments_loudness_max_times)
  te_loudness_max_times_clu[is.na(te_loudness_max_times_clu)] = 0.02
  pred_test2 = predict(TrainFunc2, newdata = te_loudness_max_times_clu)
  te_indep_x$loudness_max_times = pred_test2
  
  ## third and forth features 
  for (i in 1:12){
    te_segments_pitchess_clu = scale(te_segments_pitchess[[i]])
    te_segments_pitchess_clu[is.na(te_segments_pitchess_clu)] = 0.02
    pred_test.1 = predict(TrainFunc3[[i]],newdata = te_segments_pitchess_clu)
    te_indep_x[,i+2] = pred_test.1
    names(te_indep_x)[i+2] = paste0("segments_pitches.",i)
  }
  
  for (i in 1:12){
    te_segments_timbres_clu = scale(te_segments_timbres[[i]])
    te_segments_timbres_clu[is.na(te_segments_timbres_clu)] = 0.02
    pred_test.2 = predict(TrainFunc4[[i]], newdata = te_segments_timbres_clu)
    te_indep_x[,i+14] = pred_test.2
    names(te_indep_x)[i+14] = paste0("segments_timbre",i)
  }
  rownames(te_indep_x) = substr(rownames(te_indep_x), 3 , nchar(rownames(te_indep_x))-3)
  test_X = te_indep_x
  test_X$song = as.numeric(substring(rownames(test_X),9,nchar(rownames(test_X))))
  test_X = test_X[order(test_X$song),] 
  test_X = test_X[,-27]
  for (i in 1:26){
    test_X[[i]] = as.factor(test_X[[i]])
  }
  out = test_X
}

### fit in the model that alreaady built to do prediction, culculate and transform the results to fit in required 
word_recomend = function(test,trainfunc){
  pred = round(predict(trainfunc, newdata = test))
  pred[pred<0] = 0
  topic_freq = apply(pred,1,function(x) x/sum(x))
  word_freq = t(topic_freq)%*%t(words_freq)
  word_freq[,c(1,2,5:29)] = NA
  rank = t(apply(word_freq,1,function(x) rank(-x,ties.method= "random",na.last = "keep")))
  out = rank
}


################################## Test Data and Results ####################################
##### import data 
setwd("~/Desktop/Project4_data/TestSongFile100") ## your testing data own directory
test.file = dir(".", recursive=TRUE, full.names=TRUE)

### implement the test functions to get the results 
testx = test_X(testfiles = test.file ,TrainFunc1 = cl_1,TrainFunc2 = cl_2 ,TrainFunc3 = cl_3,TrainFunc4 = cl_4)
wordrank = word_recomend(test = testx, trainfunc = multi_fit)
head(wordrank)

### Save for use 
write.csv(wordrank,"~/Desktop/Project4_data/wordsRank_1.csv")
