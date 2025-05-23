#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# ACME: HOOK
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2025/03/481a0666-eb21-555f-858f-0c2d695b9a74/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# Sources.
SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )" # Source directory.
SRC_NAME="$( basename "$( readlink -f "${BASH_SOURCE[0]}" )" )" # Source name.
# shellcheck source=/dev/null
. "${SRC_DIR}/${SRC_NAME%.*}.conf" # Loading configuration file.

# Parameters.
DATA=("${DATA:?}"); readonly DATA
SERVICES=("${SERVICES[@]:?}"); readonly SERVICES
CRT="${LEGO_CERT_PATH:?}"; readonly CRT
KEY="${LEGO_CERT_KEY_PATH:?}"; readonly KEY
PEM="${LEGO_CERT_PEM_PATH:?}"; readonly PEM
PFX="${LEGO_CERT_PFX_PATH:?}"; readonly PFX

# -------------------------------------------------------------------------------------------------------------------- #
# IF SERVICE
# -------------------------------------------------------------------------------------------------------------------- #

function _if_svc() {
  systemctl list-units --type='service' --state='running' | grep -Fq "${1}" && return 0 || return 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATES
# -------------------------------------------------------------------------------------------------------------------- #

function cert() {
  [[ ! -d "${DATA}" ]] && mkdir -p "${DATA}"
  for i in "${CRT}" "${KEY}" "${PEM}" "${PFX}"; do
    install -u 'root' -g 'root' -m '0644' "${i}" "${DATA}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# SERVICES
# -------------------------------------------------------------------------------------------------------------------- #

function svcs() {
  for s in "${SERVICES[@]}"; do _if_svc "${s}" && systemctl reload "${s}"; done
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN
# -------------------------------------------------------------------------------------------------------------------- #

function main() { cert && svcs; }; main "$@"
