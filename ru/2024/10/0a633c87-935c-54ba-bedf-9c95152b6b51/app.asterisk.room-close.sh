#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #
# ASTERISK: CLOSING ROOM
# If there is only 1 user left in the room, the room is closed.
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2024/10/0a633c87-935c-54ba-bedf-9c95152b6b51/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# Sources.
SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )" # Source directory.
SRC_NAME="$( basename "$( readlink -f "${BASH_SOURCE[0]}" )" )" # Source name.
# shellcheck source=/dev/null
. "${SRC_DIR}/${SRC_NAME%.*}.conf" # Loading configuration file.

# Variables.
mapfile -t rooms < <( grep '^conf =>' '/etc/asterisk/meetme.conf' | cut -d ' ' -f 3 )

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { close; }

# -------------------------------------------------------------------------------------------------------------------- #
# ROOM CLOSE
# -------------------------------------------------------------------------------------------------------------------- #

close() {
  for room in "${rooms[@]}"; do
    for phone in "${phones[@]:?}"; do
      local users; users=$( asterisk -x "meetme list ${room}" | head -n -1 | awk '{ print NR }' )
      local last; last=$( asterisk -x "meetme list ${room}" | grep "${phone}" | awk '{ print $4 }' )

      case ${users} in
        1) [[ ${phone} -eq ${last} ]] && asterisk -x "meetme kick ${room} all" ;;
        *) continue ;;
      esac
    done
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
