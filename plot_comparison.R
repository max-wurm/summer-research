# plotting constant, exponential and bottleneck functions - created by Max Wurm: last edited 25/01/18
# Description: this code produces a plot showing a constant, exponential and bottleneck function (as functions of the specified values).
#   The specification should be in a .txt file, containing the names of the parameters on the first line, then the values on the second line.
#   The order should be N_0 min, N_0 max, growth rate, bottleneck min time, bottleneck max time, bottleneck resize factor

# user set parameters
T = 500 # number of generations to plot for

# read parameters
spec <- read.table("specification.txt", header = TRUE)
thenames <- names(spec)

# get plotting data into a dataframe
constant_min <- rep(spec[[1]],T+1)
constant_max <- rep(spec[[2]],T+1)
exponential_min = spec[[1]]*exp(spec[[3]]*0:T)
exponential_max = spec[[2]]*exp(spec[[3]]*0:T)
bottleneck_min = c(rep(spec[[1]],spec[[5]]),rep(spec[[6]]*spec[[1]],T+1 - spec[[5]]))
bottleneck_max = c(rep(spec[[2]],spec[[4]]),rep(spec[[6]]*spec[[2]],T+1 - spec[[4]]))
botmean <- floor((spec[[4]] + spec[[5]])/2)
bottleneck_mean = c(rep((bottleneck_min[1]+bottleneck_max[1])/2, botmean), rep((bottleneck_min[T]+bottleneck_max[T])/2,T+1 - botmean))

alldata <- data.frame(Time = 0:T,
                      conmin = constant_min,
                      conmax = constant_max,
                      conmean = (constant_min + constant_max)/2,
                      expmin = exponential_min,
                      expmax = exponential_max,
                      expmean = (exponential_min + exponential_max)/2,
                      botmin = bottleneck_min,
                      botmax = bottleneck_max,
                      botmean = bottleneck_mean)

# make plot
allmodels <- ggplot(alldata, aes(x = Time)) +
  geom_ribbon(aes(ymin = conmin, ymax = conmax, fill = "constant"), alpha = 0.3, fill = "green", color = "green", linetype = "dashed") + 
  geom_ribbon(aes(ymin = expmin, ymax = expmax, fill = "exponential"), alpha = 0.3, fill = "blue", color = "blue", linetype = "dashed") +
  geom_ribbon(aes(ymin = botmin, ymax = botmax, fill = "bottleneck"), alpha = 0.3, fill = "red", color = "red", linetype = "dashed") +
  geom_line(aes(y = conmean), color = "green", alpha = 1, linetype = "solid") +
  geom_line(aes(y = expmean), color = "blue", alpha = 1, linetype = "dashed") +
  geom_line(aes(y = botmean), color = "red", alpha = 1, linetype = "dashed")

# allmodels # uncomment to display the plot when run

# save the plot
ggsave(filename = "allmodels.pdf", plot = allmodels, device = "pdf")
