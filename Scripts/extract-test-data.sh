#!/bin/sh

# set -v
set -x

tmp_dir=${HOME}/tmp/otb-test-data

bname=`basename $0`
ext="log"


usage()
{
    echo "$1: [-x] <otb-data-dir> [ctest-options]"
    echo
    echo "Dislplay all open system calls to files in <otb-data-dir> from ctest [<ctest-options>]."
    echo
    echo "  -x Display extended output"
}


unique_basename()
{
    # echo "${bname}.$$.`date +%Y-%m-%d-%H-%M-%S.%N`"
    echo "${bname}"
}


create_tmp_dir()
{
    if [ ! -d ${tmp_dir} ]
    then
	mkdir -p ${tmp_dir}
    fi
}


delete_tmp_dir()
{
    rm -r ${tmp_dir}
}


strace_command()
{
    # stdbuf -oL strace -e trace=openat $1
    # strace -o $2 -e trace=openat $1

    filename=$2.$3.${ext}

    strace -o ${filename} -e trace=openat $1 1> $2.stdout$.{ext}
    cat ${filename} | cut -f2 -d\" | sort -u >> $2.${ext}

    rm ${filename}
}


filter_ctest()
{
    stdbuf -oL ctest -VV -N |
	(
	    i=0

	    # command = ""
	    # label = ""
	    # id = ""

	    echo "" > $2.${ext}
	    echo "" > $2.stdout.${ext}

	    while read -r command
	    do
		# if [ ${i} -eq 100 ]
		# then
		#     break
		# fi

		# Count one line.
		i=$(( i + 1 ))

		# Exit when reaching last entry.
		if echo "${command}" | grep -Eq "^Total[[:space:]]Tests:[[:space:]][[:digit:]]+$"
		then
		    number=`echo ${command} | cut -f2 -d':'`
		    echo "Number of test: ${number}"
		    break
		fi

		# echo ${command}

		# Skip lines until next test command.
		if ! echo ${command} | grep -Eq "^[[:space:]]*([[:digit:]]+):[[:space:]]Test command:[[:space:]](.+)$"
		then
		    # echo "${i}: Skipped"
		    continue
		fi

		# Extract test id and command-line.
		index=`echo ${command} | cut -f1 -d':'`
		command=`echo ${command} | cut -f3 -d':' | tr -d \"`

		# echo ${index}
		# echo ${command}

		# Count one line.
		i=$(( i + 1 ))

		# Read label line or exit if failure
		if ! read -r label
		then
		    echo "ERROR:${i}: Unable to read label line." 1>&2
		    exit 2
		fi

		skip_label=false

		# echo "${i}: ${label}"

		# Exit if label line does not follow command line.
		if ! echo ${label} | grep -Eq "^Labels:[[:space:]].+$"
		then
		    # Some tests don't have labels so, the label-line is not output by ctest.
		    skip_label=true
		else
		    # Extract test label.
		    label=`echo ${label} | cut -f2 -d':'`
		fi

		# echo ${label} 1>&2

		# Read test name of exit if failure
		if ${skip_label}
		then
		    echo "WARNING:${i}: Skipping label line." 1>&2
		    name=${label}
		else
		    # Count one line.
		    i=$(( i + 1 ))

		    # Read identification line.
		    if ! read -r name
		    then
			echo "ERROR:${i}: Unable to read identification line." 1>&2
			exit 3
		    fi
		fi

		# echo "${i}: ${name}"

		# Exit if name line does not follow label line.
		if ! echo ${name} | grep -Eq "^[[:space:]]*Test[[:space:]]+#[[:digit:]]+:[[:space:]].+$"
		then
		    echo "ERROR:${i}: Unexpected identification-line format." 1>&2
		    echo ${name} 1>&2
		    exit 4
		fi

		# Extract test name.
		name=`echo ${name} | cut -f2 -d':'`

		# echo ${name}

		# echo "${index}: ${name} ${label}"
		# echo ${command}

		# echo "${index} ${label} ${name}" 1>&2
		# echo "${command}" 1>&2

		$1 "${command}" $2 ${index}
	    done

	    echo "Number of lines: ${i}"

	    cat $2.${ext} | sort -u
	)
}


filter_strace_openat()
{
    filename=$1.${ext}
    tmp_filename=$1.strace.${ext}

    strace -f -q -o ${tmp_filename} -e trace=openat ctest $3

    cat ${tmp_filename} | grep "openat(" | cut -f2 -d\" | grep $2 | sort -u > ${filename}

    cat ${filename} 1>&2

    # rm ${tmp_filename}
}


##
## main
##

##
## Quick check command-line.
if [ $# -lt 1 ]
   then
       usage ${bname}
       exit 1
fi

##
     ## Parce command-line arguments.
while [ true ]
do
    case ${arg} in
	-x) extended=1
	    shift
	    ;;

	*) break
	   ;;
    esac
done

otb_data_dir=$1
shift

# Check otb-data dir.
if [ -z $otb_data_dir ]
then
    usage ${bname}
    exit 1
fi

##
## Crate temporary dir if needed.
create_tmp_dir

##
## Main task.

# filter_ctest strace_command ${tmp_dir}/`unique_basename`
# filter_ctest echo
# filter_strace_openat ${tmp_dir}/${bname} "otb-data" "-L OTBAppClassification"
filter_strace_openat ${tmp_dir}/${bname} $1 "$*"

# unique_filename

# delete_tmp_dir
