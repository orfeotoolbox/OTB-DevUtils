#!/bin/sh

# set -v
# set -x

tmp_dir=${HOME}/tmp/otb-test-data

bname=`basename $0`


unique_filename()
{
    # echo "${bname}.$$.`date +%Y-%m-%d-%H-%M-%S.%N`"
    echo "${bname}.log"
}


usage()
{
    echo "$1"
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
    rm ${tmp_dir}
}


strace_command()
{
    # stdbuf -oL strace -e trace=openat $1
    # strace -o $2 -e trace=openat $1
    strace -e trace=openat $1 2>&1 | cut -f2 -d\"
}


filter_ctest()
{
    stdbuf -oL ctest -VV -N |
	(
	    i=0

	    # command = ""
	    # label = ""
	    # id = ""

	    while read -r command
	    do
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
		    exit 1
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

		echo "${index} ${label} ${name}" 1>&2
		echo "${command}" 1>&2

		$1 "${command}"
	    done

	    echo "Number of lines: ${i}"
	)
}


##
## main
##

create_tmp_dir

filter_ctest strace_command ${tmp_dir}/`unique_filename`
# filter_ctest echo

# unique_filename

# delete_tmp_dir
