# -*- coding: utf-8 -*-
"""
Created on Thu Jan 25 12:05:47 2018

Code for making .est files to use in fastsimcoal2.

Description: The file specification.txt should contain the parameter names on the first line,
    and the values on the next line, separated by tabs. The order of the
    parameters matters - make sure the order is consistent with the .tpl file

@author: Max Wurm
"""

import os, sys, pandas as pd, shutil
os.chdir(os.path.dirname(sys.argv[0])) # get current path and set as cd

# reads the parameter specification file
mydata = pd.read_csv('specification.txt', sep = '\t', header = 0)
mynames = mydata.columns

# these indices refer to the order of the parameters in specification.txt
con_indices = [0,1] # indices of paramaters to use in constant .est file
exp_indices = [0,1,2] # "" exponential .est file
bot_indices = [0,1,3,4,5] # "" bottleneck .est file
all_indices = list(range(len(mydata.columns))) # all possible indices
resize_index = 5 # quick fix to set this parameter to 1 rather than 0

# create .est files for writing to
shutil.copy('template_EST.est','constant.est')
shutil.copy('template_EST.est','exponential.est')
shutil.copy('template_EST.est','bottleneck.est')

# read the template data
with open('template_EST.est') as TemplateFile:
    template = TemplateFile.read()

# iterate over all models
for indices, fname in (con_indices, 'constant.est'), (exp_indices, 'exponential.est'), (bot_indices, 'bottleneck.est'):
    tempdata = template
    # replace chosen flags with the parameter values
    for i in indices:
        flagname = 'FLAG' + str(i) + '$'
        replacement = str(float(mydata[mynames[i]]))
        tempdata = tempdata.replace(flagname,replacement) 
    # replace all other flags with 0
    for j in list(set.symmetric_difference(set(indices), set(all_indices))):
        flagname = 'FLAG' + str(j) + '$'
        if j == resize_index:
            tempdata = tempdata.replace(flagname,str(1))
        else:
            tempdata = tempdata.replace(flagname,str(0))
    # write to file
    with open(fname, 'w') as FILE:
        FILE.write(tempdata)