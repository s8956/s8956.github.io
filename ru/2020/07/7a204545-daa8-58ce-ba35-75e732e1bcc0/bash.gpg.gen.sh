#!/usr/bin/env -S bash -e
#
# Creating a new GPG key.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2020/07/7a204545-daa8-58ce-ba35-75e732e1bcc0/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID == 0 )) && { echo >&2 'This script should not be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CREATING AND EXPORT KEY.
# -------------------------------------------------------------------------------------------------------------------- #

key() {
  name="${1}"
  mail="${2}"
  pass="${3}"

  # Creating key.
  gpg --batch --gen-key <<EOF
Key-Type: EDDSA
Key-Curve: ed25519
Subkey-Type: ECDH
Subkey-Curve: cv25519
Name-Real: ${name}
Name-Email: ${mail}
Expire-Date: 0
Passphrase: ${pass}
%commit
EOF

  # Export public key.
  gpg --batch --armor \
    --output "${mail}.public.asc" \
    --export "${mail}"

  # Export private key.
  gpg --batch --armor --pinentry-mode=loopback --yes \
    --passphrase "${pass}" \
    --output "${mail}.private.asc" \
    --export-secret-keys "${mail}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

"$@"
