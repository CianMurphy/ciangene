repo=/cluster/project8/vyp/exome_sequencing_multisamples/ciangene/

export repo

pipeline=${repo}/scripts/pipeline/pipeline_cian_gene.sh


script=cluster/submission/cian.sh
rootODir=/scratch2/vyp-scratch2/ciangene


step1=yes
step2=no


sh ${pipeline} --step1 ${step1} --step2 ${step2} --rootODir ${rootODir} 

