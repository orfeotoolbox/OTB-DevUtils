#!/bin/sh

bname=`basename $0`
ext="log"
tmp_dir=/tmp


if [ $# -lt 1 ]
then
    echo "${bname} <dir>..." 1>&2
    exit 1
fi


inotifywait -mq -e open -r -o ${tmp_dir}/inotify.${ext} $*
