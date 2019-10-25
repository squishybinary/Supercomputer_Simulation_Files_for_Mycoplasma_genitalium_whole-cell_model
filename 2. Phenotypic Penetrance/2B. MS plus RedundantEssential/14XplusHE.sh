#!/bin/bash -login
# Title: 14XplusHE
# Author: Joshua Rees, joshua.rees@bristol.ac.uk
# Affiliation: Minimal Genome Group, Life Sciences, University of Bristol
# Run Using: BlueGem Supercomputer and the Slurm Queue System
# Last Updated: 2018-11-23

#############################################################################################################################################################

### Create and Run a BlueGem Script (SEE end of script for BlueGem DirTree):
#CREATE locally (and MATCH to LINE 71, 77) an:
#experiment.list (named matching job name) make sure EOL = Unix, the experiment list and job name require _(underscores) rather than spaces.
#ko.list (SEE end of script for how to create KO list, named matching job name) make sure EOL = Unix

#CREATE folders (locally and transfer to OR) on BlueGem (and MATCH to LINE 67):
#OutDir, inside OutDir: /figs, /pdfs folders AND endtimes.txt. Create the /experiment folders from exp.list. Create simulation folders for the number of simulations in /OutDir/Experiment.
#Use foldercreator.sh to create the simulation folders locally, then copy from system directory to filezilla. Or use copy_folder_structure.txt cmd on BlueGem to copy existing folder structure. 

#CHANGE: 
#date LINE 6
#number of arrays(=number of simulations) LINE 54
#output directory, sbatch output (apart from CTRL-H) LINE 67, 58
#background fig name (if different from default 'WildTypeBackground.fig') LINE 82
#CTRL-H (Job Name = BlueGem output directory = exp list and ko list names)

#CHECK: 
#runGraphs, compareGraphs, WildTypeBackgroundFig/N in Master Directory on BlueGem, MGGRunner.m in /runners folder

#UPLOAD: 
#script to script directory
#ko.list to ko.list folder
#exp.list to exp.list folder

#ACTIONS: 
#Make script executable: chmod u+x _name_ 
#Run Script on BlueGem: sbatch _name_ 
#Check progress: squeue -u _username_ 
#Check errors/progress: vi slurm_jobnumber_.out (SHIFT-G for end of file, :q! to quit file)

#############################################################################################################################################################

### Constant Slurm Variables
echo 'Task ID is:'
echo ${SLURM_ARRAY_TASK_ID}
echo 'Job ID is:'
echo ${SLURM_ARRAY_JOB_ID}
#SBATCH --time=0-30:00:00 # Max Time of Job
#SBATCH -n 1 # Number of Nodes
#SBATCH -p cpu # BlueGem Queue 
#SBATCH -A Flex1 # Umbrella Project Name

### Changeable Slurm Variables
# Number of Sims 
#SBATCH --array=1-222 	
# Name of Job
#SBATCH --job-name=14XplusHE
# Location of Log Output
#SBATCH --output=/projects/flex1/jr0904/output/MGS_Paper_SI_Data/14XplusHE/slurm-%A_%a.out

#############################################################################################################################################################

### Declarations
# WholeCell-master directory on BlueGem that contains analysis files
Master=/home/jr0904/WholeCell-master/WholeCell-master

# Directory to contain simulation output
OutDir=/projects/flex1/jr0904/output/MGS_Paper_SI_Data/14XplusHE

# Variables passed to analysis
# Fetch the Experiment name from the Exp list file
experiment_list=/home/jr0904/BlueGem/ExpLists/14XplusHE_exp.list
Umbrella=14XplusHE
Experiment=$(awk NR==${SLURM_ARRAY_TASK_ID} ${experiment_list})
Sim=${SLURM_ARRAY_TASK_ID}

# Fetch the Gene Knock Outs from the KO list file
ko_list=/home/jr0904/BlueGem/KOLists/14XplusHE_ko.list

Gene=$(awk NR==${SLURM_ARRAY_TASK_ID} ${ko_list})

# Appropiate Background Figure
BackgroundFig='WildTypeBackground.fig'

# SeedInc variable passes the Array(/Sim) Number to the MGGRunner subclass for Random Seed calculation
SeedInc=${SLURM_ARRAY_TASK_ID}

#############################################################################################################################################################

### Simulation Section
# Backup Command: ensures Simulation Directory exists. Folders should have been created previously.
mkdir -p ${OutDir}/${Experiment}/${Sim}

# Change directory to WholeCell-master 
cd ${Master}

# Load the matlab module 
module load apps/matlab-r2013a

# Set matlab options to a variable 
options="-nodesktop -noFigureWindows -singleCompThread"

# Run the simulation with matlab options
# Turn on Diary, Add Master Directory to Path, Run Simulation using MGGRunner and KO list logging the output in the designated Output Directory, Turn off Diary
matlab $options -r "diary('${OutDir}/${Experiment}/${Sim}/diary.out');addpath('${Master}');setWarnings();setPath();runSimulation('runner','MGGRunner','logToDisk',true,'outDir','${OutDir}/${Experiment}/${Sim}','seedIncrement','${SeedInc}','koList',{{${Gene}}});diary off;exit;"

#############################################################################################################################################################

### Analysis Section
# Change Directory to Sim Folder
cd ${OutDir}/${Experiment}/${Sim}

# Check for Simulation output, if present > continue
if [ -f "state-0.mat" ]; then
	# Load the matlab module 
	module load apps/matlab-r2013a

	# Set matlab options to a variable 
	options="-nodesktop -noFigureWindows -singleCompThread"

	# Run the analysis with matlab options
	# Add Master Directory to Path, runGraphs produces a set of 4x2 graphs which are initial analysis of the data, compareGraphs overlays runGraphs output on a background of 200 wildtype simulations
	matlab $options -r "addpath('${Master}');runGraphs('${Experiment}','${Sim}','${Umbrella}');compareGraphs('${Experiment}','${Sim}','${BackgroundFig}');exit;"
fi

#############################################################################################################################################################

# Post End of Analysis in BlueGem								
# Move pdfs and figs to accessible folders for downloading with FileZilla
# find /projects/flex1/jr0904/output/MGS_Paper_SI_Data/14XplusHE -type f -iname "*.pdf" -exec mv -t /projects/flex1/jr0904/output/MGS_Paper_SI_Data/14XplusHE/pdfs {} +
# find /projects/flex1/jr0904/output/MGS_Paper_SI_Data/14XplusHE -type f -iname "*.fig" -exec mv -t /projects/flex1/jr0904/output/MGS_Paper_SI_Data/14XplusHE/figs {} +

#############################################################################################################################################################

### BlueGem Directory Tree

#BlueGem
#|
#- home
#	- WholeCell-master
#		- WholeCell-master
#			-runGraphs.m , compareGraphs.m, WildTypeBackground.fig
#	- BlueGem
#		- BlueGemScripts
#			-script.sh
#		- KOLists
#			-ko.list
#		- ExpLists
#			-exp.list
#- projects
#	- flex1
#		- ... (user)
#			- output
#				- ... (project folder)
#					- sim output (n folders containing state.mat, summary.mat, and output .pdf / .fig files)

#############################################################################################################################################################

### Creating KO List
# (\w\w\w\w\w\w)
# '\1',

# 1. Copy your column of genes from a spreadsheet
# 	1a. Remove EOL Line Symbols using \n\r and nothing, in Extended Mode
# 2. Put ' ', around the Genes
# 	CTRL-H in Notepad++
# 	Find What: (\w\w\w\w\w\w) (e.g. searching for nnn = (\w\w\w) )
#	Replace With: '\1',
#	Tick Regular Expression option
#	Hit Replace_All
# 3. Put all the Genes on one line. 
#	CTRL-A in Notepad++
#	CTRL-J
# 4. Remove all blank spaces from the line. 
#	CTRL-H in Notepad++
#	Find What:         (just enter a single space on this line)
#	Replace With:      (put nothing in this box)
#	Hit Replace_All
# 5. Repeat the Simulations line as Needed
#	CTRL-A in Notepad++
#	CTRL-C 
#	CTRL-V