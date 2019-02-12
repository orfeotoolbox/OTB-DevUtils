#!/bin/sh

# set -v
# set -x

bname=`basename $0`
ext="log"
tmp_dir=/tmp


usage()
{
    echo "${bname} [-v] <dir>..." >&2
    echo "  -h Help" >&2
    echo "  -V Verbose: print files without extension to stderr" >&2
}


verbose=""


while getopts hV option ;
do
    case "${option}" in

	h) usage()
	   exit 0
	   ;;

	V) verbose="true"
	   ;;

	\?) usage()
	    exit 1
    esac
done


shift `expr $OPTIND - 1`


if [ $# -eq 0 ]
then
    usage()
    exit 2
fi


for dir in $*
do
    file `find ${dir} -type f` | grep "ASCII" | cut -f1 -d: |
	(
	    while read -r filename
	    do
		ext=${filename##*.}
		if [ ${filename} != ${ext} ]
		then
		    echo ${ext}
		fi
	    done
	) | sort -u

    # grep -r -m 1 "^" ${dir} | grep "^ASCII file" | sed -r 's:^ASCII\sfile\s(.*)\smatches:\1:g'  |
    # 	(
    # 	    while read -r filename
    # 	    do
    # 		ext=${filename##*.}

    # 		# if filename has and extension...
    # 		if [ ${filename} != ${ext} ]
    # 		then
    # 		    # ...Output extension to stdout.
    # 		    echo ${ext}
    # 		elif [ -n ${verbose} ]
    # 		then
    # 		     # ...Output it to stderr for further filtering
    # 		     echo ${filename} >&2
    # 		fi
    # 	    done
    # 	) | sort -u
done
