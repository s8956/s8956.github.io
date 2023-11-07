#!/usr/bin/bash -e
#
# Script for automatically deleting outdated files.
#
# @package    Bash
# @author     Kitsune Solar <mail@kitsune.solar>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/articles/2021/08/ca744dce-e607-52e6-9952-8ae04e052a5b/
# -------------------------------------------------------------------------------------------------------------------- #

days="${1}"
dir="${2}"

find "${dir}" -type f -mtime +${days} -print0 | xargs -0 rm -f

exit 0
