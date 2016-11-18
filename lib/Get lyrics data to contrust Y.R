library(NLP)
library(tm)
library(lda)
library(LDAvis)
library(servr)
############### get lyrics data 
load("~/Desktop/Project4_data/lyr.RData")  # your own directory
lyr_cleaned = lyr[,-1]
f_words = colSums(lyr[,-1])
term.table = f_words
vocab_m = names(term.table)
trackid  = lyr[,1]
rownames(lyr_cleaned) = trackid

get.terms = function(x) {
  index = which(x != 0)
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents = apply(lyr_cleaned,1, get.terms)

############################################# Fit the LDA model ##########################################
D = length(documents)  # number of documents (2,350)
W = length(vocab_m)  # number of terms in the vocab (5,000)
doc.length = sapply(documents, function(x) sum(x[2, ])) 
N = sum(doc.length)  # total number of tokens in the data
term.frequency = as.integer(term.table)  # frequencies of terms in the corpus 

## parameters 
K = 20
G = 5000
alpha = 0.02
eta = 0.02

## Fit the model:
set.seed(2016)
fit = lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab_m, 
                                  num.iterations = G, alpha = alpha, 
                                  eta = eta, initial = NULL, burnin = 0,
                                  compute.log.likelihood = TRUE)


## model Visualization 
theta = t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi = t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

Lyrics = list(phi = phi,
              theta = theta,
              doc.length = doc.length,
              vocab = vocab_m,
              term.frequency = term.frequency)

# create the JSON object to feed the visualization:
json = createJSON(phi = Lyrics$phi, 
                  theta = Lyrics$theta, 
                  doc.length = Lyrics$doc.length, 
                  vocab = Lyrics$vocab, 
                  term.frequency = Lyrics$term.frequency)
serVis(json, open.browser = T)


## saved words frequence that will be used latter 
words_count = fit$topics
dim(words_count)
words_freq =  apply(words_count,1,function(x) x/sum(x))
dim(words_freq)


################################################### contrust Y ################################################
y = t(fit$document_sums)
rownames(y) = names(documents)
colnames(y) = c("topic1","topic2","topic3","topic4","topic5","topic6","topic7",
                "topic8","topic9","topic10","topic11","topic12","topic13","topic14",
                "topic15","topic16","topic17","topic18","topic19","topic20")

