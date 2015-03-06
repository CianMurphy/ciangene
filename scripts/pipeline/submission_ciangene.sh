#repo=/cluster/project8/vyp/exome_sequencing_multisamples/ciangene/
repo=/cluster/project8/vyp/cian/data/UCLex/UCLex_August/Scripts/ciangene/

export repo

pipeline=${repo}/scripts/pipeline/pipeline_cian_gene.sh


script=cluster/submission/cian.sh
# rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian/

step1=no
step2=no
step3=yes 


sh ${pipeline} --step1 ${step1} --step2 ${step2} --step3 ${step3} --rootODir ${rootODir} --release February2015

