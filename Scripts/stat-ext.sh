#!/bin/sh

# set -v
# set -x

bname=`basename $0`
tmp_dir=/tmp


usage()
{
    echo "${bname} [-h] <dir> <ext>..." >&2
    echo "  -h Help" >&2
}


verbose=""


while getopts h option ;
do
    case "${option}" in

	h) usage()
	   exit 0
	   ;;

	\?) usage()
	    exit 1
	    ;;
    esac
done


shift `expr $OPTIND - 1`


if [ $# -lt 2 ]
then
    usage
    exit 2
fi


dir=$1
shift


for ext in $*
do
    du -b `find ${dir} -name "*.${ext}"` |
    	(
    	    while read -r line
    	    do
    		echo $line | cut -f1 -d' '
	    done
    	) | sort -n
done
