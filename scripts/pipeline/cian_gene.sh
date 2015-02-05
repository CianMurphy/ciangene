## version v7

#computer=vanHeel




until [ -z "$1" ]; do
    # use a case statement to test vars. we always test $1 and shift at the end of the for block.
    case $1 in
	--oFolder)
	    oFolder=$1
	    shift;;
	--release)
	    release=$1;
	    shift;;
	--step)
	    step=$1
	    shift;;
	-* )
	    echo "Unrecognized option: $1"
	    exit 1;;
    esac
    shift
    if [ "$#" = "0" ]; then break; fi
    echo $1
done



if [[ "$step" == "1" ]]; then
    
    
fi


