:: final_simulation.bat - created by Max Wurm, last updated 05/02/2018
:: Description: Runs fastsimcoal2 simulations and gets summary statistics using arlsumstat. Make sure all the required files are in the bin folder specified below.

:: Disclaimer: comments don't always work nicely within for loops in batch scripts, so apologies for the lack of commenting within the main loop.

@echo off
setlocal ENABLEDELAYEDEXPANSION
cd %~dp0

:: Parameters
set N=10000
set E=1
set bin_folder=C:\mybin

:: Simulations
for %%I in (constant, exponential, bottleneck) do (
	IF NOT EXIST %%I mkdir %%I
	cd %%I
	for %%f in (*.arp) do del %%f
	cd ..
	set tpl_file=%%I.tpl
	set est_file=%%I.est
	fsc26 -t !tpl_file! -n %N% -e !est_file! -E %E% -q -r 1024
	for %%J in (arl_run.ars, arlsumstat64.exe, LaunchArlSumStat.sh, ssdefs.txt) do (
		copy %bin_folder%\%%J %%I
	)
	cd %%I
	bash LaunchArlSumStat.sh
	for %%J in (arl_run.ars arlsumstat64.exe LaunchArlSumStat.sh ssdefs.txt) do del %%J
	cd ..
)
