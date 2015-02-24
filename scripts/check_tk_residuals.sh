#!/bin/bash

ldak=/cluster/project8/vyp/cian/support/ldak/ldak

rootODir=$1
release=$2
#rootODir=/scratch2/vyp-scratch2/ciangene
rootODir=/scratch2/vyp-scratch2/cian
release=February2015
rootODir=${1-$rootODir}
release=${2-$release}

bDir=${rootODir}/UCLex_${release}/


missingNonMissing=$bDir"/Matrix.calls.Missing.NonMissing.sp"


ldak=/cluster/project8/vyp/cian/support/ldak/ldak
genes=/SAN/biomed/biomed14/vyp-scratch/cian/LDAK/genesldak_ref.txt
kinship=/scratch2/vyp-scratch2/cian/UCLex_${release}/TechKin_filt
data=
phenotypes=

nbGroups=$(wc -l $phenotypes) 

ldak --reml kin --grm $kinship --sp $data --pheno $phenotypes
