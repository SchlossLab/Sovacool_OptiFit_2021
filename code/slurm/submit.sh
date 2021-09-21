#!/bin/bash

##################
####  Slurm preamble

#### #### ####  These are the most frequently changing options

####  Job name
#SBATCH --job-name=OptiFit

####  Request resources here
####    These are typically, number of processors, amount of memory,
####    an the amount of time a job requires.  May include processor
####    type, too.

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=50MB
#SBATCH --time=96:00:00

#SBATCH --output=log/hpc/slurm-%j_%x.out

####  Slurm account and partition specification here
####    These will change if you work on multiple projects, or need
####    special hardware, like large memory nodes or GPUs.

#SBATCH --account=YOUR_ACCOUNT
#SBATCH --partition=standard

#### #### ####  These are the least frequently changing options

####  Your e-mail address and when you want e-mail

#SBATCH --mail-user=YOUR_EMAIL
#SBATCH --mail-type=BEGIN,END

alias snakemake_cmd="time snakemake --profile config/slurm_KLS --latency-wait 90"
source /etc/profile.d/http_proxy.sh  # required for internet on the Great Lakes cluster
for dir in $(ls subworkflows); do
    pushd subworkflows/${dir}
    snakemake_cmd
    popd
done
snakemake_cmd
