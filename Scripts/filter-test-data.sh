#!/bin/sh

# set -v
# set -x


bname=`basename $0`
tmp_dir=/tmp


if [ $# -ne 1 ]
then
    echo "${bname} <inotify-log-file>" 1>&2
    exit 1
fi


# cat $1 | grep -E ' OPEN ' | sort -u | sed -e 's,/ OPEN ,/,' |
sed -ne 's, OPEN ,,p' $1 | sort -u |
    (
	while read -r filename
	do
	    if [ -f ${filename} ]
	    then
		# Keep it...
		echo ${filename}

		# ...And add existing multi-baseline components, if any.
		fbasename=${filename%.*}
		fext=${filename##*.}

		# If file is not a multi-baseline component.
		if ! echo ${filename} | grep -Eq "^"${fbasename}".[[:digit:]]+".${fext}"$"
		then
		    i=1

		    while [ -f ${fbasename}.${i}.${fext} ]
		    do
			echo "Multi-baseline: "${fbasename}.${i}.${fext} 1>&2
			echo ${fbasename}.${i}.${fext}
			i=$((i+1))
		    done
		fi
	    else
		echo "Skipped: ${filename}" 1>&2
	    fi
	done
    )
