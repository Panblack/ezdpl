#!/bin/bash
if [[ $# -lt 2 ]]; then
    echo "compress-log.sh <dir> <days before>"
    exit 1
fi
_dir=$1
_days=$2
if [[ ! -d $_dir ]]; then
    echo "$_dir does not exist";exit 1
fi
if [[ $_days -le 0 ]]; then
    echo "$_days <= 0";exit 1
fi
for x in `find -type f -mtime +${_days}|egrep -v "\.gz$"`; do
    if [[ `stat --format=%s ${x}` != 0 ]]; then
        gzip ${x}
    fi
done
