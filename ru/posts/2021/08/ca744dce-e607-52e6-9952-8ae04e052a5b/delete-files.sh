#!/usr/bin/bash

days="${1}"
dir="${2}"

find "${dir}" -type f -mtime +${days} -print0 | xargs -0 rm -f

exit 0
