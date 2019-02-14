#!/bin/sh

# set -v
# set -x

bname=`basename $0`
tmp=/tmp


usage()
{
    echo "${bname} [-v] <dir> <ext>..." >&2
    echo "  -h Help" >&2
}


verbose=""


while getopts hV option ;
do
    case "${option}" in

	h) usage
	   exit 0
	   ;;

	\?) usage
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
    for filename in `find ${dir} -type f -name "*.${ext}"`
    do
	bname=${filename%.*}

	if [ ! -f ${bname} ]
	then
	    # echo "Removing: ${filename}"
	    mv ${filename} ${tmp}

	elif [ "${bname}" = "${bname##*.}" ]
	then
	    # echo "Renamming: ${bname}"
	    mv ${bname} ${bname}.raw && mv ${bname}.${ext} ${bname}.raw.${ext}

	else
	    echo "Skipped ${filename}" >&2

	fi
    done
done
