############# Make up the full dataset 
full.data = merge(X, y,by="row.names", all=TRUE)
dim(full.data)
head(full.data)

############# Construct multivariate regression 
data.model = full.data[,-1]
multi_fit = lm(cbind(topic1,topic2,topic3,topic4,topic5,topic6,topic7,topic8,topic9,topic10,
                     topic11,topic12,topic13,topic14,topic15,topic16,topic17,topic18,topic19,topic20)~.,data = data.model)
# Check for the results 
head(round(multi_fit$fitted.values))
head(data.model[27:46])
