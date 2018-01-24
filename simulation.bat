:: simulation.bat
:: Created by Max Wurm
:: Last updated 13-12-2017
:: ----------------------------------------------------------------------------------------------
:: Description: this code simulates and performs analysis on DNA sequence data
:: Below is an overview of the pipeline
	:: fastsimcoal2 -> .arp files
	:: .arp -> [Python script, template] -> .xml
	:: .xml -> [BEAST2] -> .log, .trees
	:: .log -> Tracer (data visualisation)
	:: .log, .trees -> Tracer (Bayesian Skyline Reconstruction)

:: ----------------------------------------------------------------------------------------------

@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Parameters ----
	:: runtype dictates whether to use parameter files (param) or template/estimation files (tplest) for fastsimcoal2 simulations
	:: it is assumed that the .par or .tpl/.est files are in the same folder as this batch file
	:: the flag parameter indicates whether to do BEAST analysis (1) or summary statistics (anything else)
	:: the bin folder should contain fsc26.exe, beast.jar, PGDSpider2-cli.exe, tracer.jar and all of the following files for arlsumstat:
		:: arl_run.ars, arlsumstat64.exe, LaunchArlSumStat.sh, ssdefs.txt

cd %~dp0
set N=1
set E=1
set bin_folder=C:\mybin
set TemplateName=template3.xml

:: flags
set runtype=param
set beastflag=1
set deletexml=0
set deletelog=0
set deletetrees=0
set opentracer=1

:: decide which kind of simulation to do
IF %runtype%==param (
	for %%f in (*.par) do set param_file=%%f
	set param_folder=!param_file:~0,-4!
	goto ParamMarker
)
IF %runtype%==tplest (
	for %%f in (*.tpl) do set tpl_file=%%f
	for %%g in (*.est) do set est_file=%%g
	set param_folder=!tpl_file:~0,-4!
	goto TplEstMarker
)

:ParamMarker
IF NOT EXIST %param_folder% mkdir %param_folder%
:: get rid of old simulations
cd %param_folder%
for %%f in (*.arp) do del %%f
cd ..
:: do simulations (parameter file)
fsc26 -i %param_file% -n %N% -q
goto PostSimulation


:TplEstMarker
:: get rid of old simulations
IF NOT EXIST %param_folder% mkdir %param_folder%
cd %param_folder%
for %%f in (*.arp) do del %%f
cd ..
:: do simulations (tpl/est files)
fsc26 -t %tpl_file% -n %N% -e %est_file% -E %E% -q
goto PostSimulation


:PostSimulation
:: decide whether to do BEAST analysis
IF %beastflag%==1 (
	goto BeastMarker
)
:: If not, then get summary statistics
:: copy arlequin stuff into folder and set that folder as the cd
for %%I in (arl_run.ars, arlsumstat64.exe, LaunchArlSumStat.sh, ssdefs.txt) do (
	copy %bin_folder%\%%I %param_folder%
)
cd %param_folder%

:: get summary statistics from arlequin
bash LaunchArlSumStat.sh

:: delete arlequin stuff from folder
for %%I in (arl_run.ars arlsumstat64.exe LaunchArlSumStat.sh ssdefs.txt) do (
	del %%I
)

:: move output summary statistics into main folder
move outSumStats.txt .. & cd .. & ren outSumStats.txt "%param_folder%SumStats.txt"
pause
goto :eof


:: ----------------------------------------------------------------------------------------------


:BeastMarker
:: delete old xml files?
cd xml_files
IF NOT EXIST old_files (
	mkdir old_files
)
IF %deletexml%==1 (
	for %%f in (*.xml) do del %%f
) ELSE (
	for %%f in (*) do move %%f old_files
)
cd ..
:: run python script to convert .arp files into .xml files 
:: note: the parameter folder and template filename are sent as input
echo python "%~dp0data_to_xml.py" %1 %param_folder%
python "%~dp0data_to_xml.py" %1 %param_folder% %TemplateName%


:: Create .log file(s) from .xml using BEAST
cd log_files
IF NOT EXIST old_files (
	mkdir old_files
)
IF %deletelog%==1 (
	for %%l in (*.log) do del %%l
) ELSE (
	for %%l in (*) do move %%l old_files
)
IF %deletetrees%==1 (
	for %%t in (*.trees) do del %%t
) ELSE (
	for %%t in (*) do move %%t old_files
)
for %%I in (..\xml_files\*.xml) do (
	echo %%I
	java -jar %bin_folder%\beast.jar %%I
)


:: open a log file in tracer to view (will do the last one if N > 1)
for %%f in (*.log) do set mylog=%%f
IF %opentracer%==1 (
	java -jar %bin_folder%\tracer.jar !mylog!
)

::#####################################################################################################################
:: UNUSED -- convert all .arp files into nexus files with PGDSpider
::for %%I in (*.arp) do (
	::copy NUL ..\nexus_files\%%~nI.nex
	::%bin_folder%\PGDSpider2-cli.exe -inputfile %%I -outputfile ..\nexus_files\%%~nI.nex -spid ..\conversion_info.spid
::)

