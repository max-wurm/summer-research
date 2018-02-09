# Linear Discriminant Analysis
# Classification of Population dynamics from DNA summary statistics
# Created by F. Willsmore, 12/1/2018

# Import Libraries

library(tidyverse)
library(MASS)

#### Functions ####

# Load summary statistics into dataframe

source("importss.R")

# remove zero columns and duplicate columns

source("stripdf.R")

# performance measures

source("perform_measure.R")


# Collect data into dataframe

ss.data <- importss()

ss.data <- stripdf(ss.data)

# correlation of variables

cor(subset(ss.data,select = -class))
# Pi_1 is highly correlated with S_1
# H_1 is highly correlated with K_1

ss.data <- subset(ss.data, select = -c(H_1,Pi_1)) 

# Randomly split into train and test data

set.seed(879)

train_ind <- sample(seq_len(nrow(ss.data)), 0.7*nrow(ss.data))
train <- ss.data[train_ind,]
test<- ss.data[-train_ind,]
 
#### LDA ####

fit.lda <- lda(class ~ ., train, prior = rep(1/3,3))

#### Test Data ####

pred.lda <- predict(fit.lda, subset(test,select = -class))$class
cnf.lda <- table(predicted = pred.lda, true = test$class)
cnf.lda

performance.measures(cnf.lda,1)

#### ROC ####

# one vs all
prob.lda <- predict(fit.lda, subset(test,select = -class))$posterior

# btl vs all
# 1 is btl
btl.true <- as.integer(test$class=='btl')
pred.btl <- prob.lda[,1]
rs.btl <- roc(btl.true,pred.btl)

# const vs all
# 1 is const
const.true <- as.integer(test$class=='const')
pred.const <- prob.lda[,2]
rs.const <- roc(const.true,pred.const)

# exp vs all
# 1 is exp
exp.true <- as.integer(test$class=='exp')
pred.exp <- prob.lda[,3]
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

