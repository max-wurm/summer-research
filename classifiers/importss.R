# Import summary statistics of DNA sequences from a cloned repositry 
# Created F.R. Willsmore, 12/12/2017

importss <- function(){
  
  # Get data from Github repositry
  
  const <- read.table("~/Documents/Github/summer-research/simulations/first run/outSumStats_constant3_n1_E500.txt",header = TRUE)
  exp <- read.table("~/Documents/Github/summer-research/simulations/first run/outSumStats_exponential3_n1_E500.txt",header = TRUE)
  btl <- read.table("~/Documents/Github/summer-research/simulations/first run/outSumStats_bottleneck3_n1_E500.txt",header = TRUE)
  
  ss <- rbind(const,exp,btl)
  ss$class <- c(rep("const",nrow(const)),rep("exp",nrow(exp)),rep("btl",nrow(btl))) %>% factor
  
  return(ss)
  
}
