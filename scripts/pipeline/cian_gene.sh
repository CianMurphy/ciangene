

Rbin=/cluster/project8/vyp/vincent/Software/R-3.1.2/bin/R


firstStep=/cluster/project8/vyp/exome_sequencing_multisamples/ciangene/scripts/first.step.R

##### default value of all arguments
rootODir=/scratch2/vyp-scratch2/cian
release=August2014



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
	--step)
	    shift
	    step=$1;;
	-* )
	    echo "Unrecognized option: $1"
	    exit 1;;
    esac
    shift
    if [ "$#" = "0" ]; then break; fi
    echo $1
done


if [ -e $script ]; then rm $script; fi


if [[ "$step" == "1" ]]; then
    
    echo "

$Rbin CMD BATCH --no-save --no-restore --release=${release} --rootODir=${rootODir} $firstStep cluster/R/step1.Rout

" >> $script

    
fi




ls -ltrh $script

