#!/bin/sh

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
	    if ! echo ${command} | grep -Eq "^([[:digit:]]+):[[:space:]]Test command:[[:space:]](.+)$"
	    then
		echo "${i}: Skipped"
		continue
	    fi

	    # Extract test id and command-line.
	    index=`echo ${command} | cut -f1 -d':'`
	    command=`echo ${command} | cut -f3 -d':'`

	    echo ${index}
	    # echo ${command}

	    # Count one line.
	    i=$(( i + 1 ))

	    # Read label line or exit if failure
	    if ! read -r label
	    then
		exit 1
	    fi

	    # echo "${i}: ${label}"

	    # Exit if label line does not follow command line.
	    if ! echo ${label} | grep -Eq "^Labels:[[:space:]].+$"
	    then
		exit 2
	    fi

	    # Extract test label.
	    label=`echo ${label} | cut -f2 -d':'`

	    echo ${label}

	    # Count one line.
	    i=$(( i + 1 ))

	    # Read test name of exit if failure
	    if ! read -r name
	    then
		exit 3
	    fi

	    # echo "${i}: ${name}"

	    # Exit if name line does not follow label line.
	    if ! echo ${name} | grep -Eq "^[[:space:]]*Test[[:space:]]+#[[:digit:]]+:[[:space:]].+$"
	    then
		echo "${i}: Malformed test-name line" 1>&2
		exit 4
	    fi

	    # Extract test name.
	    name=`echo ${name} | cut -f2 -d':'`

	    echo ${name}
	done

	echo "Number of lines: ${i}"
    )
