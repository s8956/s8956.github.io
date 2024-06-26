#!/usr/bin/env -S bash -e
#
# OpenSSL self signed certificate generator.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/articles/2023/10/6733cb51-62a0-5ed9-b421-8f08c4e0cb18/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID == 0 )) && { echo >&2 'This script should not be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# Get 'openssl' command.
ossl="$( command -v openssl )"

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

# The fully-qualified domain name (FQDN) (e.g., www.example.com).
host="${1:-example.com}"

# Your email address.
email="mail@${host}"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

! [[ -x "${ossl}" ]] && { echo >&2 "'openssl' is not installed!"; exit 1; }

echo "" && echo "--- [SSL] Self Signed Certificate: '${host}'" && echo ""

if [[ "${2}" = 'rsa' ]]; then
  ${ossl} genrsa -out "${host}.key" 2048
else
  ${ossl} ecparam -genkey -name 'prime256v1' -out "${host}.key"
fi

if [[ -f "${host}.key" ]]; then
  ${ossl} req -new -sha256 -key "${host}.key" -out "${host}.csr" \
    -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/emailAddress=${email}/CN=${host}" \
    -addext 'basicConstraints = critical, CA:FALSE' \
    -addext 'nsComment = OpenSSL Generated Certificate' \
    -addext 'keyUsage = critical, digitalSignature, keyEncipherment' \
    -addext 'extendedKeyUsage = serverAuth, clientAuth' \
    -addext "subjectAltName=DNS:${host},DNS:*.${host}" \
    && ${ossl} x509 -req -sha256 -days ${days} -copy_extensions 'copyall' \
      -key "${host}.key" -in "${host}.csr" -out "${host}.crt" \
    && ${ossl} x509 -in "${host}.crt" -text -noout
else
  echo "'${host}.key' not found!" && exit 1
fi

exit 0
