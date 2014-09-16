clean_variants_file = "/scratch2/vyp-scratch2/cian/UCLex_August2014/clean_variants"

allChr_file = "/scratch2/vyp-scratch2/cian/UCLex_August2014/allChr_snpStats"

outfile = open("/scratch2/vyp-scratch2/cian/UCLex_August2014/Genotype_Matrix.sp","w")

clean_variant_dict = {}

# put keys from file in dictionary/hash
for line in open(clean_variants_file):

	clean_variant_dict[line.strip()] = 0


for line in open(allChr_file):

	ll = line.strip().split("\t")


	id_ = ll[0]

	if id_ in clean_variant_dict:

		outfile.write("\t".join(ll[1:])+"\n")

outfile.close()
