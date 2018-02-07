# Compute Macro averaging measures of a multi-class classifier
# Input: a confusion matrix (predicted class horizontal and true class vertical)
# Output: Accuracy, Error rate, Precision, Recall, F-score
# Created by F.R. Willsmore, 7/2/2018

performance.measures <- function(cnf, beta){
  
  # number of classes
  
  C <- nrow(cnf)
  
  ## Calculate binary confusion matrix per class
  
  # True Positives
  
  tp <- diag(cnf) 
  
  # False Positives
  
  fp <- rowSums(cnf)-diag(cnf)
  
  # False negatives 
  
  fn <- sum(cnf)-sum(tp)-fp
  
  # True Negatives
  
  tn <- rep(0,C)
  
  for (i in 1:C){
    tn[i] <- sum(tp)-tp[i]
  }
  
  ## Calculate Performance Measures
  
  # Calculate Accuracy
  
  Accuracy <- sum((tp+tn)/(tp + fn + fp + tn))/C
  
  # Error Rate
  
  Error.Rate <- sum((fp+fn)/(tp + fn + fp + tn))/C
  
  # Calculate Precision
  
  Precision <- sum(tp/(tp+fp))/C
  
  # Calculate Recall
  
  Recall <- sum(tp/(tp+fn))/C
  
  # Calculate Fscore
  
  beta <- beta
  
  Fscore <- ((beta^2+1)*Precision*Recall)/(beta^2*Precision+Recall)
  
  # Collate into vector
  
  measure <- cbind(Accuracy, Error.Rate, Precision, Recall, Fscore)
  
  return(measure)
  
}
