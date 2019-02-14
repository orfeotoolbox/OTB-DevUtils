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
    for filename in `find ${dir} -type f -name "${ext}"`
    do
	tmp_filename=${tmp}/${filename##*/}

	echo "Compressing: ${filename}"
	gdal_translate -co COMPRESS=LZW ${filename} ${tmp_filename}

	echo "${tmp_filename%.*}.* -> `dirname ${filename}`"
	mv ${tmp_filename%.*}.* `dirname ${filename}`
    done
done
