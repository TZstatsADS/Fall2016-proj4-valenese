# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Ran Li
+ Projec title: Predict the Most Likely Words in a Given Song
+ Project summary:
+ The main idea for this project is that different styles or topics of songs may lead to different styles of lyrics. 

+ Since the final goal for this project is use the features of music to predict a possible combination of words in its lyric. The relationship between lyric and music features should be established. A regression model between music features and lyrics may be a possible approach. In the design of regression, topics is a possible outcome while the predictors are music styles.
+ The words appear in lyrics may have some patterns within a certain topic. Thus, we may classify the songs into different topics according to the lyrics patterns. Since lyrics are created in human languages, text mining methods need to be applied in finding the patterns between lyrics. Topic models are applied in this study as text mining method. Linear discriminant analysis is applied as classification methods to classify different topics. 20 topics are selected after tuning and each topic has a “bag of word”. For each song, any word appears in the “bag” of certain topic will be recorded as 1. For example, for song1, if the value of topic1 is 15, that means the words of song1 lyric appear 15 times in topic 1. After fitting the topic model, each song will have a counts list for 20 topics. For a song counts high frequency in a certain topic, the “theme” of this song is likely to be in related with the words in the “bag” of this topic.
+ Under each topic, the frequency of each word can be counted. Thus, a posterior probability for each word under this certain topic can be calculated and the rank of probability can be calculated as well.
+ Because the data structures of music features varied a lot, the first step of treat music features will be a data structure standardize method. In “analysis” part of those h5 files, 15 features are extracted from each song. Those features related with “confidence” and “start” are excluded from our model. The rest 4 features, including “segments_loudness_max”, “segments_loudness_max_time”, “segments_pitches” and “segments_timbre” are all related with music segments, which is somehow a time series data. Since the time length is different under each music, a pretreatment method need to be applied to ensure the data have same structure before running models. The length of segment data is forced to be 20, while for those longer than 20, samples are taken under every 1/20 of the total length, and for those shorter than 20, data will be repeatedly recorded until it reaches the length of 20. The magnitude of each observation is also standardized to make sure 4 features are weighted same in final model. 
+ In the training dataset, there are 2350 songs, if the features data are directly input into model, the outcome of regression model might be too detailed since the true mean of topic model results are counts in each “bag of word”. So, K-means cluster method according to Euclidean distance are applied for each feature, and a label of cluster would be added on each cluster. Since cluster is an unsupervised classification method, those songs assigned with same label may have some similarities on their music styles. According to visualization methods, 14 clusters are applied for “segments_loudness_max”, 25 for “segments_loudness_max_time”, 10 for “segments_pitches”, and 10 for “segments_timbre”. The labels of clusters will be used as predictors in regression models, since it is believed that if songs have the same style in all 4 features, they are very likely to have the same style in lyrics.
+ Multivariate regression is built between features clusters and topics. For any song, there will be a predicted word frequency under each topic. Those negative values in prediction outcomes will be forced to 0 since negative frequencies do not make any sense. After getting the predicted frequencies, a predicted rank of word to appear in this song can also be calculated by naïve Bayes’ theorem. 
+ While using test data to predict the rank for new songs, first thing need to be paid attention to is remove the sample_submission.csv file from the folder before run the test function script. When testing, the features of new songs will be put into the clusters set before, and use the assigned labels as predictors to find the most likely topics of these new songs. After getting the predicted topics, the rank of probability that a word appears in a certain song will be calculated according to both predicted topics and the probabilities under the topics.
  
	
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
