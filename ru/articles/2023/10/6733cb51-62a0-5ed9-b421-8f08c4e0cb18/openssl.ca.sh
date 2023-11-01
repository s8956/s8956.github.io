#!/usr/bin/bash -e
#
# OpenSSL certificate generator.
#
# @package    Bash
# @author     Kitsune Solar <mail@kitsune.solar>
# @copyright  2023 iHub TO
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/articles/2023/10/6733cb51-62a0-5ed9-b421-8f08c4e0cb18/
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
# Default is 30 days.
days='3650'

# Timestamp.
ts="$(( $( ${date} -u '+%s%N' ) / 1000000 ))"

# Suffix.
sfx=$( ${shuf} -i '1000-9999' -n 1 --random-source='/dev/random' )

ca() {
  local ec='secp384r1'

  echo "" && echo "--- [CREATE] Certificate Authority" && echo ""
  ${ossl} req -x509 -newkey ec:<( openssl ecparam -name "${ec}" ) \
    -nodes -days "${days}" \
    -keyform 'PEM' -outform 'PEM' \
    -keyout "${ca_key}" -out "${ca_crt}" \
    && ${ossl} x509 -in "${ca_crt}" -text
}

cert() {
  local ec='prime256v1'
  local key_pvt="${ts}.${sfx}.key.private.pem"
  local key_pub="${ts}.${sfx}.key.public.pem"
  local csr="${ts}.${sfx}.csr"
  local crt="${ts}.${sfx}.crt"
  local p12="${ts}.${sfx}.p12"
  local srl="${ts}.${sfx}.srl"

  echo "" && echo "--- [CREATE] Client Certificate [${ts}]" && echo ""
  ${ossl} ecparam -name "${ec}" -genkey -noout -out "${key_pvt}" \
    && ${ossl} ec -in "${key_pvt}" -pubout -out "${key_pub}" \
    && ${ossl} req -new -key "${key_pvt}" -out "${csr}" \
    && ${ossl} x509 -req -in "${csr}" \
        -CA "${ca_crt}" -CAkey "${ca_key}" -days "${days}" \
        -CAcreateserial -CAserial "${srl}" \
        -outform 'PEM' -out "${crt}" \
    && ${ossl} pkcs12 -export \
        -inkey "${key_pvt}" \
        -in "${crt}" -out "${p12}" \
    && ${ossl} verify -CAfile "${ca_crt}" "${crt}" \
    && ${ossl} x509 -in "${crt}" -text
}

"$@"
