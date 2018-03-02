#loading required libraries. Some sections are fully commented as this script can be sourced from another.
library(plyr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(e1071)
library(caret)

# READING DATA -----------------------------------------------------------------------
# #from group data files: data_1
# SSc <- read.table("outSumStats_constant.txt", header = TRUE)
# SSb <- read.table("outSumStats_bottleneck.txt", header = TRUE)
# SSe <- read.table("outSumStats_exponential.txt", header = TRUE)
# 
# #from own data: data_2
# SSc <- read.table("C:/Users/Sophie/Desktop/fsc/const_new/outSumStats_const_s.txt", header = TRUE)
# SSe <-  read.table("C:/Users/Sophie/Desktop/fsc/exp_try/outSumStats_exp_s.txt", header = TRUE)
# SSb <- read.table("C:/Users/Sophie/Desktop/fsc/bot_new/outSumStats_bot_s.txt", header = TRUE)
# 
# #(Fergus' data: data_3)
# SSc <- read.table("constSS_fergus.txt", header=TRUE)
# SSe <- read.table("expSS_fergus.txt", header=TRUE)
# SSb <- read.table("btlSS_fergus.txt", header=TRUE)
# 
# #Max's new data: data_4 (7.2.18)
# SSc <- read.table("outSumStats_constant_n1_E500.txt", header = TRUE)
# SSb <- read.table("outSumStats_bottleneck_n1_E500.txt", header = TRUE)
# SSe <- read.table("outSumStats_exponential_n1_E500.txt", header = TRUE)
# 
# #Max's new new data: data_5 (8.2.18)
# SSc <- read.table("outSumStats_constant2_n1_E500.txt", header = TRUE)
# SSb <- read.table("outSumStats_bottleneck2_n1_E500.txt", header = TRUE)
# SSe <- read.table("outSumStats_exponential2_n1_E500.txt", header = TRUE)
# 
# #Fixed exponential in data_4: data_6
# SSc <- read.table("outSumStats_constant_n1_E500.txt", header = TRUE)
# SSb <- read.table("outSumStats_bottleneck_n1_E500.txt", header = TRUE)
# SSe <- read.table("outSumStats_exponential_n1_E500_redo.txt", header = TRUE)
# 
# #Fixed exponential in data_5: data_7
# SSc <- read.table("outSumStats_constant2_n1_E500.txt", header = TRUE)
# SSb <- read.table("outSumStats_bottleneck2_n1_E500.txt", header = TRUE)
# SSe <- read.table("outSumStats_exponential2_n1_E500_redo.txt", header = TRUE)

#Changes made after meeting with Ben 8.2.18: data_8
SSc <- read.table("outSumStats_constant3_n1_E500.txt", header = TRUE)
SSb <- read.table("outSumStats_bottleneck3_n1_E500.txt", header = TRUE)
SSe <- read.table("outSumStats_exponential3_n1_E500.txt", header = TRUE)

# UNIVARIATE STATISTICS ------------------------------------------------------------
#Comparing individual summary statistics for each model in a boxplot

#NB: variable and graph_name must be a character string in " "
boxplot_comparison <- function(var_name, graph_name){

relevant_stats <- as.data.frame(cbind(SSc[[var_name]], SSe[[var_name]], SSb[[var_name]]))
colnames(relevant_stats) <- c("constant", "exponential", "bottleneck")

long_stats <-   suppressMessages(melt(relevant_stats)) #melts data into long format without outputting an unnecessary message.

ggplot(long_stats, aes(variable,value))+
  geom_boxplot() +
  coord_flip() +
  labs(x = "Population Model", y = "Value", title=paste0(" ", graph_name, " (",var_name,") for each Population Model"))+
  theme_dark()
}

# CLEANING DATA -------------------------------------------------------------------

#selects the usual non-zero columns of data frame df and adds a column of "classlab", type character.
#dplyr dependency
sel.label <- function(df,classlab){
  df %>% 
    dplyr::select(K_1,H_1,Hsd_1,tot_H,S_1,D_1,FS_1,Pi_1) %>%
    mutate(
      popClass = c(rep(paste0("",classlab,""), nrow(df)))
    )
}

c <- sel.label(SSc,"const")
e <- sel.label(SSe, "exp")
b <- sel.label(SSb, "btl")

popn.data <- rbind(c,e,b) #concatenates data frames for analysis

popn.data$popClass <- as.factor(popn.data$popClass) #ensures not class "character"
popn.data[ ,1:8] <- as.vector(popn.data[ ,1:8]) #ensures numeric

# FILTER METHODS ------------------------------------------------------
cor_mat <- cor(popn.data[ ,1:8]) #variables with high correlation: S_1/Pi_1, K_1/H_1, tot_H/D_1 (data_1)
(rm_cor_cols <- findCorrelation(cor_mat, cutoff = 0.8))


#Removing features as advised by rm_cor_cols; 
#data_1: Pi_1, H_1, tot_H.
#data_2: K_1, Pi_1.
#data_3: K_1, Hsd_1, Pi_1.
#data_4: Pi_1, H_1, tot_H.
#data_5: Pi_1, H_1, tot_H.

#data_8: Pi_1, H_1 at 0.8 level

remove_features <- function(data){ 
data$Pi_1 <- NULL 
data$H_1 <- NULL
#data$tot_H <- NULL
#data$Hsd_1 <- NULL
return(data)
}

popn.data <- remove_features(popn.data)
c <- remove_features(c)
e <- remove_features(e)
b <- remove_features(b)

#scaling is automatic as part of the svm function, so not required.

#splitting data (new) 70% train, 30% test
set.seed(879)
train.ind <- sample(seq_len(nrow(popn.data)), 0.7*nrow(popn.data))
train.data <- popn.data[train.ind, ]
pred.data <- popn.data[-train.ind, ]

#fixing class issues again!
train.data$popClass <- as.factor(train.data$popClass)
train.data[ , 1:6] <- as.vector(train.data[ , 1:6])


# DEFINING SVMs ----------------------------------------------------------
three.lin <- svm(popClass~. , data=train.data, kernel="linear", type="C-classification", probability=TRUE)
three.rbf <- svm(popClass~. , data=train.data, kernel="radial", type="C-classification",probability=TRUE)

#optim.~ SVMs have hyperparameters as given by the best.parameters attribute from the tune function.
optim.lin <- svm(popClass~. , data=train.data, kernel="linear", cost = 0.18, type="C-classification", probability=TRUE)
optim.rbf <- svm(popClass~. , data=train.data, gamma = 0.3, cost=2, kernel="radial", type="C-classification", probability=TRUE)

# PREDICTING SVMs ---------------------------------------------------------
pred.lin <- predict(three.lin,  pred.data, decision.values=TRUE, probability = TRUE)
pred.rbf <- predict(three.rbf,  pred.data, decision.values=TRUE, probability = TRUE)
pred.opt.rbf <- predict(optim.rbf,  pred.data, decision.values=TRUE)
pred.opt.lin <- predict(optim.lin,  pred.data, decision.values=TRUE)

# PERFORMANCE SCORES, ETC.--------------------------------------------------
(cm.lin <- confusionMatrix(pred.lin, pred.data$popClass))
cm.lin$table

(cm.rbf <- confusionMatrix(pred.rbf, pred.data$popClass))
cm.rbf$table

(cm.opt.lin <- confusionMatrix(pred.opt.lin, pred.data$popClass))
cm.opt.lin$table

(cm.opt.rbf <- confusionMatrix(pred.opt.rbf, pred.data$popClass))
cm.opt.rbf$table


# HYPERPARAMETER OPTIMISATION ---------------------------------------------------
# #even if only two values are used for both gamma and cost, computation time is still impractical (>= 30 min).
# tune.rbf <- tune(svm, popClass~. , data = train.data, kernel = "radial", ranges = list(gamma=seq(0.15,0.25,0.05), cost = seq(1.5,2.5,0.1)), 
#                  tunecontrol = tune.control(sampling="cross"))
# #data_2: first search returned gamma = 1, cost = 4. Narrower search gave gamma = 0.8, cost = 4.4.
# #data_4: ""  "" gamma = 32, cost = 8 (i.e. maximum values. Not great.)
# #data_5: gamma=0.125, cost = 0.5
# 
# #data_8: init gamma=0.25, cost = 1. Again: gamma = 0.35, cost = 0.6
# 
# tune.lin <- tune(svm, popClass~. , data=train.data, kernel = "linear", ranges = list(cost = 2^(seq(-4,2,0.5))))
# #Cost of 0.065 is best for data_2.

# PROGRESS NOTES ------------------------------------------------------------------------
#19.01.18
#TL;DR - it's still pretty terrible at distinguishing between constant and bottleneck models.

#22.01.18
#Fixed (somewhat): was using the wrong bottleneck data. 
#Cost does more-or-less nothing compared to gamma parameter. Cost = 20 resulted in a slightly better 
#classification of the constant model, but that's it.
#based on contingency tables, rbf kernel does a better job of classifying than linear kernel, 
#but not by that much.

#23.01.18
#Added functions for data cleaning

#24.01.18
#CONFLICTS WITH MASS PACKAGE. `select` in MASS can mask `select` in dplyr



