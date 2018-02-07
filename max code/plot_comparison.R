# plotting constant, exponential and bottleneck functions - created by Max Wurm: last edited 25/01/18
# Description: this code produces a plot showing a constant, exponential and bottleneck function (as functions of the specified values).
#   The specification should be in a .txt file, containing the names of the parameters on the first line, then the values on the second line.
#   The order should be N_0 min, N_0 max, growth rate min, growth rate max, NANC min, NANC max, bottleneck min time, bottleneck max time, bottleneck resize factor
#   (NANC is the population size that you want after the exponential model becomes constant)

# user set parameters
T = 500 # number of generations to plot for

# read parameters
spec <- read.table("specification.txt", header = TRUE)
thenames <- names(spec)

# get plotting data into a dataframe
constant_min <- rep(spec$NPOP_min,T+1)
constant_max <- rep(spec$NPOP_max,T+1)
exponential_min = spec$NPOP_min*exp(spec$GROWTH_max*0:T) # this is before replacing the later values with a constant model
exponential_max = spec$NPOP_max*exp(spec$GROWTH_min*0:T) # ""
bottleneck_min = c(rep(spec$NPOP_min - spec$BOTDIFF, spec$TBOT_max), rep(spec$NPOP_min + spec$BOTDIFF, T+1 - spec$TBOT_max))
bottleneck_max = c(rep(spec$NPOP_max - spec$BOTDIFF, spec$TBOT_min), rep(spec$NPOP_max + spec$BOTDIFF, T+1 - spec$TBOT_min))
botmean <- floor((spec$TBOT_min + spec$TBOT_max)/2)
bottleneck_mean = c(rep((bottleneck_min[1]+bottleneck_max[1])/2, botmean), rep((bottleneck_min[T]+bottleneck_max[T])/2,T+1 - botmean))

# replace exponential things
exptime_min = (1/spec$GROWTH_max) * log(spec$NANC_min/spec$NPOP_min)
exptime_max = (1/spec$GROWTH_min) * log(spec$NANC_max/spec$NPOP_max)
exponential_min[exptime_min:(T+1)] = rep(spec$NANC_min,T+2-exptime_min)
exponential_max[exptime_max:(T+1)] = rep(spec$NANC_max,T+2-exptime_max)

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
  geom_ribbon(aes(ymin = conmin, ymax = conmax, colour = "constant"), alpha = 0.3, fill = "green", color = "green", linetype = "dashed") + 
  geom_ribbon(aes(ymin = expmin, ymax = expmax, colour = "exponential"), alpha = 0.3, fill = "blue", color = "blue", linetype = "dashed") +
  geom_ribbon(aes(ymin = botmin, ymax = botmax, colour = "bottleneck"), alpha = 0.3, fill = "red", color = "red", linetype = "dashed") +
  geom_line(aes(y = conmean), color = "green", alpha = 1, linetype = "dashed") +
  geom_line(aes(y = expmean), color = "blue", alpha = 1, linetype = "dashed") +
  geom_line(aes(y = botmean), color = "red", alpha = 1, linetype = "dashed") +
  theme_classic() +
  labs(y = "Estimated Population Size", title = "Model Comparison", x = "Time (generations before present)") +
  scale_colour_manual(values = c("constant" = "green", "exponential" = "blue", "bottleneck" = "red"), labels = c("constant","exponential","bottleneck"))

allmodels # uncomment to display the plot when script is run

# save the plot
ggsave(filename = "figures/allmodels.png", plot = allmodels, device = "png")
