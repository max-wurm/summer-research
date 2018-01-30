# summer-research
files for summer research December 2017 - February 2018

## figures
This folder contains plots and graphs used in the project

## max code
To run these scripts, place them all in a folder and make sure all programs required (fsc26.exe, beast.jar etc.) are on the system path. The directory should contain the .par or .tpl/.est files required for simulation, all template files and the specification.txt file

- simulation.bat: this script semi-automates creating sequence data with fastsimcoal2 and running them through BEAST using an xml template file.
- data_to_xml.py: this script is called by simulation.bat and puts the sequence data into xml format to be processed by BEAST2.
- plot_skyline.R: this plots a Bayesian Skyline Plot, using output from Tracer.
- plot_comparison.R: this plots the extreme values of all three models (constant, exponential, bottleneck) on a single axis, given the specification file specification.txt. This is to see whether the models look similar, and judge the characterisation model appropriately.
- read_spec.py: this script reads specification.txt and creates three .est files containing the specified parameters. These are then used with the template_TPL.tpl file to run fastsimcoal2 simulations.
- specification.txt: this file contains two rows of data - the names and values of parameters to be used in fastsimcoal2 simulations. Entries should be tab separated, and there should be a blank bottom line. The parameters here do not have to have the same names as the parameters in the template_TPL.tpl file; however, they DO have to have the same ORDER as the flags 'FLAGX$' in that file. FLAG0$ should be replaced with the first parameter listed in specification.txt, FLAG1$ with the second and so on.