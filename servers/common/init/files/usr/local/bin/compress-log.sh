#!/bin/bash
_dir=$1
_days=$2
if [[ -z $_dir ]] && [[ -z $_days ]]; then
    echo "compress-log.sh <dir> <days before>"
    exit 1
fi
cd $_dir
for x in `find -type f -mtime +${_days}|egrep -v "\.gz$"`; do
    if [[ `stat --format=%s ${x}` != 0 ]]; then
        gzip ${x}
    fi
done
