#!/usr/bin/env -S bash -eu
# -------------------------------------------------------------------------------------------------------------------- #
# FAVICON.ICO
# Generating 'favicon.ico' file.
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2021/05/841ba281-a22b-55ee-b97d-251a5dc111d8/
# -------------------------------------------------------------------------------------------------------------------- #

size=( 16 24 32 48 64 72 80 96 128 144 152 167 180 192 196 256 300 512 )
svg='favicon.svg'
ico='favicon.ico'

png() {
  _check_file
  for i in "${size[@]}"; do
    rsvg-convert -w "${i}" -h "${i}" "${svg}" -o "favicon-${i}.png"
  done
}

ico() {
  _check_file
  convert -density '256x256' -background 'transparent' "${svg}" -define 'icon:auto-resize' -colors '256' "${ico}"
  identify "${ico}"
}

_check_file() {
  [[ -f "${svg}" ]] || { printf '%s does not exist!\n' "${svg}"; exit 1; }
}

"$@"
