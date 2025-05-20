#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# OPENSSL SELF SIGNED CERTIFICATE GENERATOR
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2023/10/6733cb51-62a0-5ed9-b421-8f08c4e0cb18/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID == 0 )) && { echo >&2 'This script should not be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

# Specifies the number of days to make a certificate valid for.
# Default is 10 years.
DAYS='3650'

# The two-letter country code where your company is legally located.
COUNTRY='RU'

# The state/province where your company is legally located.
STATE='Russia'

# The city where your company is legally located.
CITY='Moscow'

# Your company's legally registered name (e.g., YourCompany, Inc.).
ORG='LocalHost'

# Your company's organizational unit.
OU='IT Department'

# Common name (CN). The fully-qualified domain name (FQDN) (e.g., www.example.com).
CN="${1:?}"

# Your email address.
EMAIL='mail@localhost'

# Additional subject identities.
SAN="${2}"; [[ -z "${2}" ]] && SAN="DNS:${CN}, DNS:*.${CN}, DNS:*.localdomain, DNS:*.local, IP:127.0.0.1"

# Key usage extensions.
KU="${3}"; [[ -z "${3}" ]] && KU='digitalSignature, nonRepudiation, keyEncipherment'

# Extended key usage.
EKU="${4}"; [[ -z "${4}" ]] && EKU='serverAuth, clientAuth'

# Certificate authority.
CA="${5:-FALSE}"

# -------------------------------------------------------------------------------------------------------------------- #
# TITLE
# -------------------------------------------------------------------------------------------------------------------- #

function _title() {
  echo '' && echo "${1}" && echo ''
}

# -------------------------------------------------------------------------------------------------------------------- #
# GENERATOR
# Creating a self-signed certificate.
# -------------------------------------------------------------------------------------------------------------------- #

function gen() {
  _title "--- [SSL] SELF SIGNED CERTIFICATE: '${CN}'"
  openssl ecparam -genkey -name 'prime256v1' | openssl ec -out "${CN}.key" \
    && openssl req -new -sha256 \
    -key "${CN}.key" \
    -out "${CN}.csr" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}" \
    -addext "basicConstraints = critical, CA:${CA}" \
    -addext 'nsCertType = server, client' \
    -addext 'nsComment = OpenSSL Self-Signed Certificate' \
    -addext "keyUsage = critical, ${KU}" \
    -addext "extendedKeyUsage = ${EKU}" \
    -addext "subjectAltName = ${SAN}" \
    && openssl x509 -req -sha256 -days "${DAYS}" -copy_extensions 'copyall' \
    -key "${CN}.key" -in "${CN}.csr" -out "${CN}.crt" \
    && openssl x509 -in "${CN}.crt" -text -noout
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN
# -------------------------------------------------------------------------------------------------------------------- #

function main() { gen; }; main "$@"
