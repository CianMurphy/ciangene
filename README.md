ciangene
========

[![Join the chat at https://gitter.im/CianMurphy/ciangene](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/CianMurphy/ciangene?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
Order of scripts: in progress


* first.step.R

		Takes the snpStats files from the data release and turn into a numeric matrix
		Same thing but with depth, prepares the kinshpi matrix computation
		Takes the list of clean variants and outputs the filtered result

* variant_filtering
		
		variant_filtering/snp_subet_extCtrls.R

* convert_missingNonmissing_matrix_to_plink.sh

		turns NA/non NA into 0-1 for LDAK/plink use

* make_kinships_new.sh

		###Computes variant weights, then computes kinship matrix based on depth and missing/non-missing
		###Three sets of weights: two kinship matrices and genotypes.
		###Why? Need to understand why we use weights from genotype matrix.

* new_make_phenotype_file.R

		Creates a large matrix of phenotypes, grouped by names basically.

* check_tk_residuals.sh
		
		Checks how much variance TK explains for all phenos (A). Creates new pheno files, using residuals from (A) as phenos. 

* LDAK/run_ldak_on_all_phenos.sh

		gene tests - all UCLex phenos, with and without kinship

* plink_single_variant_tests.sh

		single variant tests - Fisher, logistic regression with and without techPC covariates 

* run_fastLMM_on_all_phenotypes.sh 
	
		first, run prepare_kinship_matrix_for_fastLMM.R

		single variant tests - FastLMM - Linear Regression / Mixed model with and without techKin


* merge_gene_tests.sh
	
		Doesn't just merge. Also uses permuted pvalue in regress1..regressN to define null distribution (permuted pheno with kin) to calc final pvalue in regressALL. Script hangs when run on just one chunk/gene (eg as per power studies). 

* summarise.results.R


* plot_results.R

		 gene tests
