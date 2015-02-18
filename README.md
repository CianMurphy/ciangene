ciangene
========

[![Join the chat at https://gitter.im/CianMurphy/ciangene](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/CianMurphy/ciangene?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
Order of scripts: in progress


* first.step.R

		Takes the snpStats files from the data release and turn into a numeric matrix
		Same thing but with depth, prepares the kinshpi matrix computation
		Takes the list of clean variants and outputs the filtered result

* convert_missingNonmissing_matrix_to_plink.sh

		turns NA/non NA into 0-1 for LDAK/plink use

* make_kinships.sh

		#Computes variant weights, then computes kinship matrix based on depth and missing/non-missing
		#Three sets of weights: two kinship matrices and genotypes.
		#Why? Need to understand why we use weights from genotype matrix.

* make_phenotype_file.R

		Creates a large matrix of phenotypes, grouped by names basically.

* LDAK/run_ldak_on_all_phenos.sh

		gene tests - all UCLex phenos, with and without kinship

* run_single_variant.sh

		single variant tests - Fisher

* run_fastLMM_on_all_phenotypes.sh 

		single variant tests - FastLMM - Linear Regression / Mixed model with and without techKin


* merge_gene_tests.sh


* summarise.results.R


* plot_results.R

		 gene tests
