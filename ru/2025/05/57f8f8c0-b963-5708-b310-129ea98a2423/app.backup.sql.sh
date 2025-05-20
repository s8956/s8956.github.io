#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# SQL DATABASE BACKUP.
# Backup of PostgreSQL and MariaDB databases.
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/2025/05/57f8f8c0-b963-5708-b310-129ea98a2423/
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# Sources.
SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )" # Source directory.
SRC_NAME="$( basename "$( readlink -f "${BASH_SOURCE[0]}" )" )" # Source name.
# shellcheck source=/dev/null
. "${SRC_DIR}/${SRC_NAME%.*}.conf" # Loading configuration file.

# Parameters.
SQL_SRC=("${SQL_SRC[@]:?}"); readonly SQL_SRC
SQL_DST="${SQL_DST:?}"; readonly SQL_DST
SQL_USER="${SQL_USER:?}"; readonly SQL_USER
SQL_PASS="${SQL_PASS:?}"; readonly SQL_PASS
ENC_ON="${ENC_ON:?}"; readonly ENC_ON
ENC_APP="${ENC_APP:?}"; readonly ENC_APP
ENC_PASS="${ENC_PASS:?}"; readonly ENC_PASS
SYNC_ON="${SYNC_ON:?}"; readonly SYNC_ON
SYNC_HOST="${SYNC_HOST:?}"; readonly SYNC_HOST
SYNC_USER="${SYNC_USER:?}"; readonly SYNC_USER
SYNC_PASS="${SYNC_PASS:?}"; readonly SYNC_PASS
SYNC_DST="${SYNC_DST:?}"; readonly SYNC_DST
SYNC_DEL="${SYNC_DEL:?}"; readonly SYNC_DEL
SYNC_RSF="${SYNC_RSF:?}"; readonly SYNC_RSF
SYNC_PED="${SYNC_PED:?}"; readonly SYNC_PED
SYNC_CVS="${SYNC_CVS:?}"; readonly SYNC_CVS

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: ERROR
# -------------------------------------------------------------------------------------------------------------------- #

function _err() {
  echo >&2 "[$( date +'%Y-%m-%dT%H:%M:%S%z' )]: $*"; exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: ID
# -------------------------------------------------------------------------------------------------------------------- #

function _id() {
  date -u '+%s'
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: TIMESTAMP
# -------------------------------------------------------------------------------------------------------------------- #

function _timestamp() {
  date -u '+%Y-%m-%d.%H-%M-%S'
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: DIRECTORY TREE
# -------------------------------------------------------------------------------------------------------------------- #

function _tree() {
  echo "$( date -u '+%Y' )/$( date -u '+%m' )/$( date -u '+%d' )"
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: DATABASE BACKUP
# -------------------------------------------------------------------------------------------------------------------- #

function _mysql() {
  local db; db="${1}"
  local cmd; cmd='mariadb-dump'; [[ "$( command -v 'mysqldump' )" ]] && cmd='mysqldump'
  "${cmd}" --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-3306}" \
    --user="${SQL_USER:-root}" --password="${SQL_PASS}" --databases="${db}" \
    --single-transaction --skip-lock-tables
}

function _pgsql() {
  local db; db="${1}"
  PGPASSWORD="${SQL_PASS}" pg_dump --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-5432}" \
    --username="${SQL_USER:-postgres}" --no-password --dbname="${db}" \
    --clean --if-exists --no-owner --no-privileges --quote-all-identifiers
}

function _dump() {
  local dbms; dbms="${1%%.*}"
  local db; db="${1##*.}"
  case "${dbms}" in
    'mysql') _mysql "${db}" ;;
    'pgsql') _pgsql "${db}" ;;
    *) _err 'DBMS does not exist!' ;;
  esac
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: ENCRYPTION
# -------------------------------------------------------------------------------------------------------------------- #

function _gpg() {
  local out; out="${1}.gpg"
  local pass; pass="${2}"
  gpg --batch --passphrase "${pass}" --symmetric --output "${out}" \
    --s2k-cipher-algo "${ENC_GPG_CIPHER:-AES256}" \
    --s2k-digest-algo "${ENC_GPG_DIGEST:-SHA512}" \
    --s2k-count "${ENC_GPG_COUNT:-65536}"
}

function _ssl() {
  local out; out="${1}.ssl"
  local pass; pass="${2}"
  openssl enc "-${ENC_SSL_CIPHER:-aes-256-cfb}" -out "${out}" -pass "pass:${pass}" \
    -salt -md "${ENC_SSL_DIGEST:-sha512}" -iter "${ENC_SSL_COUNT:-65536}" -pbkdf2
}

function _enc() {
  local out; out="${1}"
  local pass; pass="${ENC_PASS}"
  if (( "${ENC_ON}" )); then
    case "${ENC_APP}" in
      'gpg') _gpg "${out}" "${pass}" ;;
      'ssl') _ssl "${out}" "${pass}" ;;
      *) _err 'ENC_APP does not exist!' ;;
    esac
  else
    cat < '/dev/stdin' > "${out}"
  fi
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMMON: CHECKSUM
# -------------------------------------------------------------------------------------------------------------------- #

function _sum() {
  local in; in="${1}"; (( "${ENC_ON}" )) && in="${1}.${ENC_APP}"
  local out; out="${in}.txt"
  sha256sum "${in}" | sed 's| .*/|  |g' | tee "${out}" > '/dev/null'
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN: BACKUP DATABASE
# -------------------------------------------------------------------------------------------------------------------- #

function backup() {
  local id; id="$( _id )"
  for i in "${SQL_SRC[@]}"; do
    local ts; ts="$( _timestamp )"
    local tree; tree="${SQL_DST}/$( _tree )"
    local file; file="${i}.${id}.${ts}.sql.xz"
    [[ ! -d "${tree}" ]] && mkdir -p "${tree}"; cd "${tree}" || _err "Directory '${tree}' not found!"
    _dump "${i}" | xz | _enc "${file}" && _sum "${file}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN: SYNCHRONIZATION
# -------------------------------------------------------------------------------------------------------------------- #

function sync() {
  (( ! "${SYNC_ON}" )) && return 0
  local opts; opts=('--archive' '--quiet')
  (( "${SYNC_DEL}" )) && opts+=('--delete')
  (( "${SYNC_RSF}" )) && opts+=('--remove-source-files')
  (( "${SYNC_PED}" )) && opts+=('--prune-empty-dirs')
  (( "${SYNC_CVS}" )) && opts+=('--cvs-exclude')
  rsync "${opts[@]}" -e "sshpass -p '${SYNC_PASS}' ssh -p ${SYNC_PORT:-22}" \
    "${SQL_DST}/" "${SYNC_USER:-root}@${SYNC_HOST}:${SYNC_DST}/"
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN: CLEAN FILESYSTEM
# -------------------------------------------------------------------------------------------------------------------- #

function clean() {
  find "${SQL_DST}" -type 'f' -mtime "+${SQL_DAYS:-30}" -print0 | xargs -0 rm -f --
  find "${SQL_DST}" -mindepth 1 -type 'd' -not -name 'lost+found' -empty -delete
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN
# -------------------------------------------------------------------------------------------------------------------- #

function main() {
  backup && sync && clean
}; main "$@"
