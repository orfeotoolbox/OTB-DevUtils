#!/bin/sh

bname=`basename $0`
ext="log"
tmp_dir=/tmp

inotifywait -mq -e open -r -o ${tmp_dir}/inotify.${ext} $*
