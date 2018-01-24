# -*- coding: utf-8 -*-
"""
Created on Mon Dec 11 10:02:28 2017

Code for copying data into an xml file for BEAST to handle
Put this file in the directory containing the master run file

@author: Max
"""

# import packages
import xml.etree.ElementTree as ET, re, glob, os, sys

os.chdir(os.path.dirname(sys.argv[0])) # get current path and set as cd
parfolder = sys.argv[1] # get folder name from batch file
filenames = glob.glob(parfolder + "/*.arp") # get all .arp filenames

# read in template xml file
with open(sys.argv[2]) as TemplateFile:
         template = TemplateFile.read()

for IDX, FILE in enumerate(filenames):
    # read arlequin file
    with open(FILE) as file:
        read_data = file.read()
    
    # get the number of sequences (stored in size)
    size_ind = read_data.find('SampleSize')
    size_end = read_data.find('\n', size_ind)
    size = int(read_data[size_ind+11:size_end])
    
    # get indices of where the ATCG starts/ends and subset the data
    ind1 = read_data.find('{')
    ind2 = read_data.find('}')
    subset_data = read_data[ind1+2:ind2-2]
    
    # get specific start/end locations of the ATCG data
    tablocations = [m.start() for m in re.finditer('\t', subset_data)][1::2]
    nlocations = [m.start() for m in re.finditer('\n', subset_data)]
    nlocations.append(len(subset_data))
    
    # put the ATCG strings in a list
    NucleoString = []
    for i in range(size):
        NucleoString.append(subset_data[tablocations[i]+1:nlocations[i]])
    
    # put this data into xml format
    SequenceID = ["sequence" + str(i) for i in range(1,size+1)]
    
    filename = "dummy filename"
    
    # create the xml tree structure
    xmldata = ET.Element("data", id=filenames[IDX][len(parfolder)+1:-4],
                         name="alignment")
    for i in range(size):
        sequence = ET.SubElement(xmldata, "sequence", id="seq_" + SequenceID[i],
                                 taxon=SequenceID[i], totalcount=str(4),
                                 value=NucleoString[i])
    
    # write to a template file
    tempdata = template
    tempdata = tempdata.replace("DATAGOESHERE", ET.tostring(xmldata).decode())
    tempdata = tempdata.replace("templateID", FILE[len(parfolder)+1:-4])
    
    with open("xml_files/" + FILE[len(parfolder)+1:-4] + '.xml','w+') as newfile:
        newfile.write(tempdata)
    
    # uncomment below to write just the data xml to file
    #finaltree = ET.ElementTree(xmldata)
    #finaltree.write("xml_files/" + FILE[len(parfolder)+1:-4] + ".xml")


