

Rbin=/cluster/project8/vyp/vincent/Software/R-3.1.2/bin/R


firstStep=${repo}/scripts/first.step.R  ##step 1
secondStep=${repo}/scripts/first_depth_kin.R  ## step2


##### default value of all arguments
rootODir=/scratch2/vyp-scratch2/cian
release=February2015



######## create directories
for dir in cluster cluster/submission cluster/error cluster/out cluster/R; do
    if [ ! -e $dir ]; then mkdir $dir; fi
done




until [ -z "$1" ]; do
    # use a case statement to test vars. we always test $1 and shift at the end of the for block.
    case $1 in
	--rootODir)
	    shift
	    rootODir=$1;;
	--script)
	    shift
	    script=$1;;
	--release)
	    shift
	    release=$1;;
	--step1)
	    shift
	    step1=$1;;
	--step2)
	    shift
	    step2=$1;;
	-* )
	    echo "Unrecognized option: $1"
	    exit 1;;
    esac
    shift
    if [ "$#" = "0" ]; then break; fi
    echo $1
done


hold=""


##########
if [[ "$step1" == "yes" ]]; then    

    script=cluster/submission/step1.sh

    echo "
#$ -S /bin/bash
#$ -o cluster/out
#$ -e cluster/error
#$ -l h_vmem=5.9G,tmem=5.9G
#$ -pe smp 1
#$ -N step1_cian
#$ -l h_rt=24:00:00
#$ -cwd

$Rbin CMD BATCH --no-save --no-restore --release=${release} --rootODir=${rootODir} $firstStep cluster/R/step1.Rout

" > $script

    qsub $hold $script
    if [[ "$hold" == "" ]]; then hold="-hold_jid step1_cian"; else hold="$hold,step1_cian"; fi
fi


#########
if [[ "$step2" == "yes" ]]; then    

    script=cluster/submission/step2.sh

    echo "
#$ -S /bin/bash
#$ -o cluster/out
#$ -e cluster/error
#$ -l h_vmem=5.9G,tmem=5.9G
#$ -pe smp 1
#$ -N step2_cian
#$ -l h_rt=24:00:00
#$ -cwd

$Rbin CMD BATCH --no-save --no-restore --release=${release} --rootODir=${rootODir} $secondStep cluster/R/step2.Rout

" > $script

    qsub $hold $script
    if [[ "$hold" == "" ]]; then hold="-hold_jid step2_cian"; else hold="$hold,step2_cian"; fi

fi






ls -ltrh $script

