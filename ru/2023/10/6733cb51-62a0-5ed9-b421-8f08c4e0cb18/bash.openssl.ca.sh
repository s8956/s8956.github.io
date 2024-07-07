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

# Get 'cat' command.
cat="$( command -v cat )"

# Get 'date' command.
date="$( command -v date )"

# Get 'mkdir' command.
mkdir="$( command -v mkdir )"

# Get 'openssl' command.
ossl="$( command -v openssl )"

# Get 'shuf' command.
shuf="$( command -v shuf )"

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
ts="$( ${date} -u '+%s' )"

# Suffix.
sfx=$( ${shuf} -i '1000-9999' -n 1 --random-source='/dev/random' )

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# CERTIFICATE AUTHORITY.
# -------------------------------------------------------------------------------------------------------------------- #

ca() {
  ! [[ -x "${ossl}" ]] && { echo >&2 "'openssl' is not installed!"; exit 1; }

  local name="${1:-example.com}"
  local email="${2:-mail@example.com}"
  local v3ext_ca='_CA.v3ext'

  cat > "${v3ext_ca}" <<EOF
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF

  echo '' && echo "--- [SSL-CA] CREATING A CA CERTIFICATE" && echo ''
  ${ossl} ecparam -genkey -name 'secp384r1' | ${ossl} ec -aes256 -out "${ca}.key" \
    && ${ossl} req -new -sha384 -key "${ca}.key" -out "${ca}.csr" \
    -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/emailAddress=${email}/CN=${name}" \
    && ${ossl} x509 -req -extfile "${v3ext_ca}" -sha384 -days ${days} -key "${ca}.key" -in "${ca}.csr" -out "${ca}.crt"

    _info "${ca}.crt"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CLIENT CERTIFICATE.
# -------------------------------------------------------------------------------------------------------------------- #

cert() {
  for i in "${mkdir}" "${ossl}" "${shuf}"; do
    ! [[ -x "${i}" ]] && { echo >&2 "'${i}' is not installed!"; exit 1; }
  done

  local name; name="${1:-example.com}"
  local email; email="${2:-mail@example.com}"
  local type; type="${3:-server}"; [[ "${name}" = *' '* ]] && type='client'
  local dir; dir="${type}/${name// /_}"; ${mkdir} -p "${dir}"
  local file; file="${dir}/${email}.${ts}.${sfx}"

  local v3ext
  if [[ "${type}" = 'client' ]]; then
    v3ext=$( _v3ext_client "${file}.v3ext" )
  else
    v3ext=$( _v3ext_server "${file}.v3ext" "${name}" )
  fi

  echo '' && echo "--- [SSL] CREATING A ${type^^} CERTIFICATE" && echo ''
  ${ossl} ecparam -genkey -name 'prime256v1' | ${ossl} ec -out "${file}.key" \
    && ${ossl} req -new -key "${file}.key" -out "${file}.csr" \
    -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/emailAddress=${email}/CN=${name}" \
    && ${ossl} x509 -req -extfile "${v3ext}" -days ${days} -in "${file}.csr" \
    -CA "${ca}.crt" -CAkey "${ca}.key" -CAcreateserial -CAserial "${file}.srl" -out "${file}.crt" \
    && ${cat} "${file}.key" "${file}.crt" "${ca}.crt" > "${file}.crt.chain"

  _verify "${ca}.crt" "${file}.crt" && _info "${file}.crt" && _export "${file}.key" "${file}.crt" "${file}.p12"
}

_verify() {
  echo '' && echo "--- [SSL] CERTIFICATE VERIFICATION" && echo ''
  for i in "${1}" "${2}"; do [[ ! -f "${i}" ]] && { echo >&2 "'${i}' not found!"; exit 1; }; done
  ${ossl} verify -CAfile "${1}" "${2}"
}

_info() {
  echo '' && echo "--- [SSL] CERTIFICATE DETAILS" && echo ''
  [[ ! -f "${1}" ]] && { echo >&2 "'${i}' not found!"; exit 1; }
  ${ossl} x509 -in "${1}" -text -noout
}

_export() {
  echo '' && echo "--- [SSL] EXPORTING A CERTIFICATE" && echo ''
  for i in "${1}" "${2}"; do [[ ! -f "${i}" ]] && { echo >&2 "'${i}' not found!"; exit 1; }; done
  ${ossl} pkcs12 -export -inkey "${1}" -in "${2}" -out "${3}"
}

_v3ext_client() {
  cat > "${1}" <<EOF
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
extendedKeyUsage = clientAuth, emailProtection
keyUsage = critical, digitalSignature, keyEncipherment, nonRepudiation
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
EOF
  echo -n "${1}"
}

_v3ext_server() {
  cat > "${1}" <<EOF
authorityKeyIdentifier = keyid,issuer:always
basicConstraints = CA:FALSE
extendedKeyUsage = serverAuth, clientAuth
keyUsage = critical, digitalSignature, keyEncipherment
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${2}
DNS.2 = *.${2}
IP.1 = 127.0.0.1
EOF
  echo -n "${1}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

"$@"
