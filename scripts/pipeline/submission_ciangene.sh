repo=/cluster/project8/vyp/exome_sequencing_multisamples/ciangene/

export repo

pipeline=${repo}/scripts/pipeline/cian_gene.sh


script=cluster/submission/cian.sh
rootODir=/scratch2/vyp-scratch2/ciangene

sh ${pipeline} --step 1 --rootODir ${rootODir} --script ${script}

