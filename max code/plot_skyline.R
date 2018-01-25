# Bayesian Skyline Plots for fastsimcoal data - created by Max Wurm, last edited 25/01/18
# note: the data needs to be exported after doing a Bayesian Skyline Reconstruction in Tracer
#   to get the data in the correct format, comment out the first line (wih #) and make sure the labels are on a separate line to the values

setwd("University/Third Year/summer_research/second week")

filepath <- "log_files/ben_constant.txt" # enter the path to the skyline data file here

# get the data and put it into a data frame
thedata <- read.table(filepath, header = TRUE, sep = "", comment.char = "#")

# create the skyline plot
theplot <- ggplot(thedata, aes(x = Time)) +
  geom_ribbon(aes(ymin = Lower, ymax = Upper, fill = "95% HPD"), alpha=0.3) +
  scale_colour_manual(values=c("blue","red"), name = "") +
  scale_fill_manual("",values="grey12") +
  geom_line(aes(y = Mean, color = "mean"), alpha = 1) +
  geom_line(aes(y = Median, color = "median"), alpha = 1) +
  scale_y_continuous(name = "Estimated Population") +
  scale_x_continuous(name = "Time (generations)") +
  ggtitle("Bayesian Skyline Plot: bottleneck event")

# theplot # uncomment to display the plot

# save the plot
ggsave(plot = theplot2, filename = "gg-bottleneck2.pdf",device = "pdf")
