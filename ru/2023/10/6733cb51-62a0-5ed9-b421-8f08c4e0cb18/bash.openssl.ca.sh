#!/usr/bin/env -S bash -euo pipefail
#
# OpenSSL certificate generator with CA.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.2
# @link       https://lib.onl/ru/2023/10/6733cb51-62a0-5ed9-b421-8f08c4e0cb18/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID == 0 )) && { echo >&2 'This script should not be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# CA file names.
ca='_CA'

# Specifies the number of days to make a certificate valid for.
# Default is 10 years.
days='3650'

# The two-letter country code where your company is legally located.
country='RU'

# The state/province where your company is legally located.
state='Russia'

# The city where your company is legally located.
city='Moscow'

# Your company's legally registered name (e.g., YourCompany, Inc.).
org='YourCompany'

# Timestamp.
ts="$( date -u '+%s' )"

# Suffix.
sfx="$( shuf -i '1000-9999' -n 1 --random-source='/dev/random' )"

# -------------------------------------------------------------------------------------------------------------------- #
# ERROR
# -------------------------------------------------------------------------------------------------------------------- #

function _err() {
  echo >&2 "[$( date +'%Y-%m-%dT%H:%M:%S%z' )]: $*"; exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# TITLE
# -------------------------------------------------------------------------------------------------------------------- #

function _title() {
  echo '' && echo "${1}" && echo ''
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE: VERIFY
# -------------------------------------------------------------------------------------------------------------------- #

function _verify() {
  _title '--- [SSL] CERTIFICATE VERIFICATION'
  for i in "${1}" "${2}"; do [[ ! -f "${i}" ]] && { _err "'${i}' not found!"; }; done
  openssl verify -CAfile "${1}" "${2}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE: INFO
# -------------------------------------------------------------------------------------------------------------------- #

function _info() {
  _title '--- [SSL] CERTIFICATE DETAILS'
  [[ ! -f "${1}" ]] && { _err "'${i}' not found!"; }
  openssl x509 -in "${1}" -text -noout
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE: EXPORT
# -------------------------------------------------------------------------------------------------------------------- #

function _export() {
  _title '--- [SSL] EXPORTING A CERTIFICATE'
  for i in "${1}" "${2}"; do [[ ! -f "${i}" ]] && { _err "'${i}' not found!"; }; done
  openssl pkcs12 -export -inkey "${1}" -in "${2}" -out "${3}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE: V3EXT CLIENT
# -------------------------------------------------------------------------------------------------------------------- #

function _v3ext_client() {
  cat > "${1}" <<EOF
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Client Certificate"
keyUsage = critical, digitalSignature, keyEncipherment, nonRepudiation
extendedKeyUsage = clientAuth, emailProtection
EOF
  echo -n "${1}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE: V3EXT SERVER
# -------------------------------------------------------------------------------------------------------------------- #

function _v3ext_server() {
  cat > "${1}" <<EOF
authorityKeyIdentifier = keyid,issuer:always
basicConstraints = CA:FALSE
nsCertType = server, client
nsComment = "OpenSSL Server Certificate"
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${2}
DNS.2 = *.${2}
IP.1 = 127.0.0.1
EOF
  echo -n "${1}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE AUTHORITY GENERATOR
# -------------------------------------------------------------------------------------------------------------------- #

function ca() {
  local name="${1:-example.org}"
  local email="${2:-mail@example.org}"
  local v3ext_ca='_CA.v3ext'

  cat > "${v3ext_ca}" <<EOF
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF

  _title '--- [SSL-CA] CREATING A CA CERTIFICATE'
  openssl ecparam -genkey -name 'secp384r1' | openssl ec -aes256 -out "${ca}.key" \
    && openssl req -new -sha384 -key "${ca}.key" -out "${ca}.csr" \
    -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/emailAddress=${email}/CN=${name}" \
    && openssl x509 -req -extfile "${v3ext_ca}" -sha384 -days "${days}" \
    -key "${ca}.key" -in "${ca}.csr" -out "${ca}.crt" && _info "${ca}.crt"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE GENERATOR
# -------------------------------------------------------------------------------------------------------------------- #

function cert() {
  local name; name="${1:-example.org}"
  local email; email="${2:-mail@example.org}"
  local type; type="${3:-server}"; [[ "${name}" == *' '* ]] && type='client'
  local dir; dir="${type}/${name// /_}"; mkdir -p "${dir}"
  local file; file="${dir}/${email}.${ts}.${sfx}"

  local v3ext
  if [[ "${type}" == 'client' ]]; then
    v3ext="$( _v3ext_client "${file}.v3ext" )"
  else
    v3ext="$( _v3ext_server "${file}.v3ext" "${name}" )"
  fi

  _title "--- [SSL] CREATING A ${type^^} CERTIFICATE"
  openssl ecparam -genkey -name 'prime256v1' | openssl ec -out "${file}.key" \
    && openssl req -new -key "${file}.key" -out "${file}.csr" \
    -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/emailAddress=${email}/CN=${name}" \
    && openssl x509 -req -extfile "${v3ext}" -days "${days}" -in "${file}.csr" \
    -CA "${ca}.crt" -CAkey "${ca}.key" -CAcreateserial -CAserial "${file}.srl" -out "${file}.crt" \
    && cat "${file}.key" "${file}.crt" "${ca}.crt" > "${file}.crt.chain" \
    && _verify "${ca}.crt" "${file}.crt" && _info "${file}.crt" \
    && _export "${file}.key" "${file}.crt" "${file}.p12"
}

# -------------------------------------------------------------------------------------------------------------------- #
# RUN
# -------------------------------------------------------------------------------------------------------------------- #

"$@"
