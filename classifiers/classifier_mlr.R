# Multinomial Logistic Regression with Elastic-net Penalty
# Classification of Population dynamics from DNA summary statistics
# Created by F.R. Willsmore, 2/2/2018

# import Libraries

library(tidyverse)
library(digest)
library(glmnet)
library(pROC)
library(plotmo)
library(plotROC)

#### Functions ####

# Load summary statistics into dataframe

source("importss.R")

# remove zero columns and duplicate columns

source("stripdf.R")

# performance measures

source("perform_measure.R")

#### Import Data ####

# Collect data into dataframe

ss.data <- importss()

ss.data <- stripdf(ss.data)

#### Correlation Analysis ####

cor(subset(ss.data,select = -class))

ss.data <- subset(ss.data, select = -c(H_1,Pi_1))

# Randomly split into train and test data

set.seed(879)

train_ind <- sample(seq_len(nrow(ss.data)), 0.7*nrow(ss.data))
train <- ss.data[train_ind,]
test<- ss.data[-train_ind,]

#### Model Fitiing ####

xtrain <- as.matrix(subset(train, select = -class))
ytrain <- train$class

fit.mlr <- glmnet(xtrain, ytrain, family = "multinomial", type.multinomial = "grouped")

# Lasso coefficient plot

plot_glmnet(fit.mlr, labels=TRUE, s = cvfit$lambda.1se, nresponse = 1, grid.col = "lightgrey")

# cross validation plot

cvfit <- cv.glmnet(xtrain, ytrain, family="multinomial",type.multinomial = "grouped", parallel = TRUE)

plot(cvfit)

#### Predict ####

xtest <- as.matrix(subset(test, select = -class))
ytest <- test$class

pred.mlr <- predict(fit.mlr, xtest, s = cvfit$lambda.1se, type='class')
cnf.mlr <- table(predicted = pred.mlr, true = test$class)
cnf.mlr

performance.measures(cnf.mlr,1)

### ROC ###

# one vs all
prob.mlr <- data.frame(prob.mlr)

# btl vs all
# 1 is btl
btl.true <- as.integer(test$class=='btl')
pred.btl <- prob.mlr[,1]
rs.btl <- roc(btl.true,pred.btl)

# const vs all
# 1 is const
const.true <- as.integer(test$class=='const')
pred.const <- prob.mlr[,2]
rs.const <- roc(const.true,pred.const)

# exp vs all
# 1 is exp
exp.true <- as.integer(test$class=='exp')
pred.exp <- prob.mlr[,3]
rs.exp <- roc(exp.true,pred.exp)

# plot ROC

class <- c(rep('btl', length(btl.true)), 
           rep('const', length(const.true)), 
           rep('exp', length(exp.true)))
pred <- c(pred.btl, pred.const, pred.exp)
true <- c(btl.true, const.true, exp.true)

roc.test <- data.frame(true, pred, class)

rocplot <- ggplot(roc.test, aes(d = true, m = pred)) + 
  geom_roc( n.cuts = 0) + 
  style_roc(theme = theme_grey, xlab = "1 - Specificity") +
  facet_wrap(~class,ncol = 1)
rocplot




