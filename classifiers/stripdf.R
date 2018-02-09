# Remove zero columns and duplicate rows from a dataframe.
# Created by F.R Willsmore, 4/12/2017
# Input
#     df : A dataframe
# Output 
#     df : A simplified dataframe

stripdf <- function(df){
  
  # Remove zero columns
  
  df <- df[, colSums(df != 0) > 0] 
  
  # remove duplicate columns
  
  df <- df[!duplicated(lapply(df, digest))] 
  df <- Filter(function(x)(length(unique(x))>1), df)
  
  return(df)
  
}