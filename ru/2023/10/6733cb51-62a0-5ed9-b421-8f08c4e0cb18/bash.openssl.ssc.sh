#!/usr/bin/env -S bash -e
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
days='3650'

# The two-letter country code where your company is legally located.
country='RU'

# The state/province where your company is legally located.
state='Russia'

# The city where your company is legally located.
city='Moscow'

# Your company's legally registered name (e.g., YourCompany, Inc.).
org='LocalHost'

# Your company's organizational unit.
ou='IT Department'

# Common name (CN). The fully-qualified domain name (FQDN) (e.g., www.example.com).
cn="${1:?}"

# Your email address.
email='mail@localhost'

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

! [[ -x "$( command -v 'openssl' )" ]] && { echo >&2 "'openssl' is not installed!"; exit 1; }
echo '' && echo "--- [SSL] SELF SIGNED CERTIFICATE: '${cn}'" && echo ''
openssl ecparam -genkey -name 'prime256v1' | openssl ec -out "${cn}.key" \
  && openssl req -new -sha256 \
  -key "${cn}.key" \
  -out "${cn}.csr" \
  -subj "/C=${country}/ST=${state}/L=${city}/O=${org}/OU=${ou}/CN=${cn}/emailAddress=${email}" \
  -addext "basicConstraints = critical, CA:${3:-FALSE}" \
  -addext 'nsCertType = server' \
  -addext 'nsComment = OpenSSL Generated Server Certificate' \
  -addext 'keyUsage = critical, digitalSignature, keyEncipherment' \
  -addext 'extendedKeyUsage = serverAuth, clientAuth' \
  -addext "subjectAltName = ${2:?}" \
  && openssl x509 -req -sha256 -days ${days} -copy_extensions 'copyall' \
  -key "${cn}.key" \
  -in "${cn}.csr" \
  -out "${cn}.crt" \
  && openssl x509 -in "${cn}.crt" -text -noout

exit 0
