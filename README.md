# Supercomputer_Simulation_Files_for_Mycoplasma_genitalium_whole-cell_model
Bash scripts (*.sh), gene knockout (*_ko.list), and experiment name (*_exp.list) files for producing Mycoplasma genitalium whole-cell model simulations on a SLURM controlled supercomputer cluster.


- Upload generated simulation files (*.sh, *_ko.list, *_exp.list) to location indicated in structure
- Upload runGraphs.m, compareGraphs.m, WildTypeBackground.fig, MGGrunner.m from UPLOAD_to_supercomputer folder to locations indicated in structure
- To start running the simulation files on the supercomputer (if it uses SLURM queuing system) see lines 10 - 35 of <simulation bash file>.sh (of generated simulation files) for commands

- home
	- USER
		- WholeCell-master
			- WholeCell-master
				-[WholeCell model files]
				-[runGraphs.m]
				-[compareGraphs.m]
				-[WildTypeBackground.fig]
				- src
					- +edu
						- +stanford
							- +covert
								- +cell
									- +sim
										- +runners
											-[MGGrunner.m]
		- BlueGem
			- BlueGemScripts
				-[*.sh]
			- KOLists
				-[*_ko.list]
			- ExpLists
				-[*_exp.list]

	- projects
		- GROUP
			- USER
				- output
					- PROJECTFOLDER
						- JOBx (replace with the name(*) of your *.sh file)
							- 'simname' (see lines of *_exp.list)
								- 1
									-[simulation files]
								- 2
									-[simulation files]
								- n (depending on number of simulations, see *_exp.list)
							- wildtype (not always required, depends on stage)
								- n 
							- mutant (not always required, depends on stage)
								- n
							- pdfs
							- figs
              
Data Format
-----------
The majority of output files are state-NNN.mat files, which are logs of the simulation split into 100-second segments. The data within a state-NNN.mat file is organised into 16 cell variables, each containing a number of sub-variables. 
These are typically arranged as 3-dimensional matrices or time series, which are flattened to conduct analysis. The other file types contain summaries of data spanning the simulation. 


Data Analysis Process
----------------------
The raw data is automatically processed as the simulation ends. runGraphs.m carries out the initial analysis, while compareGraphs.m overlays the output on collated graphs of 200 unmodified M.genitalium simulations. Both outputs are saved as MATLAB .fig and .pdfs,
though the .fig files were the sole files analysed. The raw .mat files were stored in case further investigation was required.
 
To classify our data we chose to use the phenotype classification previously outlined by Karr (Figure 6B 17), which graphed five variables to determine the simulated cells phenotype. However, the script responsible for producing Figure 6B, 
SingleGeneDeletions.m, was not easily modified. This led us to develop our own analysis script recreating the classification: runGraphs.m graphs growth, protein weight, RNA weight, DNA replication, cell division, ands records several experimental details. 

There are seven possible phenotypes caused by knocking out genes in the simulation: non-essential if producing a dividing cell; and essential if producing a non-dividing cell because of a DNA replication mutation, RNA production mutation, 
protein production mutation, metabolic mutation, division mutation, or slow growing. 

For the single gene knockout simulations produced in initial input, the non-essential simulations were automatically classified and the essential simulations flagged. Each simulation was investigated manually and given a phenotype manually using 
the decision tree (see Supplementary Information D). 

For simulations conducted by Minesweeper and GAMA, simulations were automatically classified solely by division, which can be analysed from cell width or the endtime of the simulation.

Further analysis, including: cross-comparison of single-gene knockout simulations, comparison to Karr et als 17 results, analysis of Minesweeper and GAMA genomes (genetic content and similarity, behavioural analysis, phenotypic penetrance, gene ontology), 
and identification and investigation of high and low essentiality genes and groupings, were completed manually. The GO term analysis of gene deletion impacts was processed by a created script, then organised into tables of GO terms 
that were unaffected, reduced, or removed entirely.


Modelling: Scripts, Process and Simulations
-------------------------------------------
Generally, there are six scripts we used to run the whole-cell model. Three are the experimental files created with each new experiment (the bash script, gene list, experiment list), and three are stored within the whole-cell model 
and are updated only upon improvement (MGGrunner.m, runGraphs.m, and compareGraphs.m). The bash script is a list of commands for the supercomputer(s) to carry out. Each new bash script is created from the GenericScript.sh template, 
which determines how many simulations to run, where to store the output, which analysis to run, and where to store the results of the analysis. The gene list is a text file containing rows of gene codes (in the format 'MG_XXX',). 
Each row corresponds to a single simulation and determines which genes that simulation should knockout. 

The experiment list is a text file containing rows of simulation names. Each row corresponds to a single simulation and determines where the simulation output and results of the analysis are stored. 
In brief, to manually run the whole-cell model: a new bash script, gene list, and experiment list are created on the desktop computer to answer an experimental question. The supercomputer is accessed on the desktop via ftp software, 
where the new experimental files are uploaded, the planned output folders are created, and MGGRunner.m, runGraphs.m, compareGraphs.m files are confirmed to be present. The supercomputer is then accessed on the desktop via ssh software, 
where the new bash script is made executable and added to the supercomputers queuing system to be executed. Once the experiment is complete, the supercomputer is accessed on the desktop via ssh software, where the results of the analysis are 
moved to /pdf and /fig folders. These folders are accessed on the desktop via ftp software, where the results of the analysis are downloaded. More detailed instructions are contained within the template bash script.
Each wild-type simulation consists of 300 files requiring 0.3GB. Each gene manipulated simulation can consist of up to 500 files requiring between 0.4GB and 0.9GB. Each simulation takes 5 to 12 hours to complete in real time, 7 - 13.89 hours in simulated time.

