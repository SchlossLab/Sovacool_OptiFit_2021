#!/bin/bash

##################
####  Slurm preamble

#### #### ####  These are the most frequently changing options

####  Job name
#SBATCH --job-name=ofa

####  Request resources here
####    These are typically, number of processors, amount of memory,
####    an the amount of time a job requires.  May include processor
####    type, too.

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2GB
#SBATCH --time=72:00:00

#SBATCH --output=log/hpc/slurm-%j.out

####  Slurm account and partition specification here
####    These will change if you work on multiple projects, or need
####    special hardware, like large memory nodes or GPUs.

#SBATCH --account=pschloss1
#SBATCH --partition=standard

#### #### ####  These are the least frequently changing options

####  Your e-mail address and when you want e-mail

#SBATCH --mail-user=sovacool@umich.edu
#SBATCH --mail-type=BEGIN,END

snakemake --profile config/slurm --latency-wait 30 --configfile config/config.yaml -s code/fit_sample_subset.smk