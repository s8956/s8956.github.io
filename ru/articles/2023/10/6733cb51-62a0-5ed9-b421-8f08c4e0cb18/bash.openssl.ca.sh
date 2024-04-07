#!/usr/bin/env -S bash -e
#
# OpenSSL certificate generator with CA.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.2
# @link       https://lib.onl/ru/articles/2023/10/6733cb51-62a0-5ed9-b421-8f08c4e0cb18/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID == 0 )) && { echo >&2 'This script should not be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# Get 'date' command.
date="$( command -v date )"

# Get 'openssl' command.
ossl="$( command -v openssl )"

# Get 'shuf' command.
shuf="$( command -v shuf )"

# CA key & certificate names.
ca_key='ca.root.key'
ca_crt='ca.root.crt'

# Specifies the number of days to make a certificate valid for.
# Default is 10 years.
days='3650'

# Timestamp.
ts="$(( $( ${date} -u '+%s%N' ) / 1000000 ))"

# Suffix.
sfx=$( ${shuf} -i '1000-9999' -n 1 --random-source='/dev/random' )

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE AUTHORITY.
# -------------------------------------------------------------------------------------------------------------------- #

ca() {
  local ec='secp384r1'

  echo "" && echo "--- [SSL] Certificate Authority" && echo ""
  ${ossl} req -x509 -newkey ec:<( openssl ecparam -name "${ec}" ) \
    -nodes -sha384 -days "${days}" \
    -keyout "${ca_key}" -out "${ca_crt}" \
    && ${ossl} x509 -in "${ca_crt}" -text -noout
}

# -------------------------------------------------------------------------------------------------------------------- #
# CLIENT CERTIFICATE.
# -------------------------------------------------------------------------------------------------------------------- #

cert() {
  local ec='prime256v1'
  local key_pvt="${ts}.${sfx}.private.key"
  local key_pub="${ts}.${sfx}.public.key"
  local csr="${ts}.${sfx}.csr"
  local crt="${ts}.${sfx}.crt"
  local p12="${ts}.${sfx}.p12"
  local srl="${ts}.${sfx}.srl"

  ! [[ -x "${ossl}" ]] && { echo >&2 "'openssl' is not installed!"; exit 1; }
  ! [[ -x "${shuf}" ]] && { echo >&2 "'shuf' is not installed!"; exit 1; }

  echo "" && echo "--- [SSL] Client Certificate [${ts}]" && echo ""
  ${ossl} ecparam -name "${ec}" -genkey -noout -out "${key_pvt}" \
    && ${ossl} ec -in "${key_pvt}" -pubout -out "${key_pub}" \
    && ${ossl} req -new -key "${key_pvt}" -out "${csr}" \
    && ${ossl} x509 -req -in "${csr}" \
        -CA "${ca_crt}" -CAkey "${ca_key}" -days "${days}" \
        -CAcreateserial -CAserial "${srl}" \
        -out "${crt}" \
    && ${ossl} pkcs12 -export \
        -inkey "${key_pvt}" \
        -in "${crt}" -out "${p12}" \
    && ${ossl} verify -CAfile "${ca_crt}" "${crt}" \
    && ${ossl} x509 -in "${crt}" -text -noout
}

"$@"
