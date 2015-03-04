#repo=/cluster/project8/vyp/exome_sequencing_multisamples/ciangene/
repo=/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/ciangene/

export repo

pipeline=${repo}/scripts/pipeline/pipeline_cian_gene.sh


script=cluster/submission/cian.sh
# rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian

step1=yes
step2=yes
step3=no ## ldak script submits jobs, which wont work when run on a job node. FIX


sh ${pipeline} --step1 ${step1} --step2 ${step2} --step3 ${step3} --rootODir ${rootODir} --release October2014

