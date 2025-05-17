#!/usr/bin/env -S bash -eu
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
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() { backup && sync && clean; }

# -------------------------------------------------------------------------------------------------------------------- #
# SQL: BACKUP
# Creating a database dump.
# -------------------------------------------------------------------------------------------------------------------- #

backup() {
  local id; id="$( _id )"
  for i in "${SQL_SRC[@]}"; do
    local ts; ts="$( _timestamp )"
    local tree; tree="${SQL_DST}/$( _tree )"
    local file; file="${i}.${id}.${ts}.sql.xz.gpg"
    [[ ! -d "${tree}" ]] && mkdir -p "${tree}"; cd "${tree}" || _err "Directory '${tree}' not found!"
    _dump "${i}" | xz | _enc "${file}" && _sum "${file}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# FS: SYNC
# Sending database dumps to remote storage.
# -------------------------------------------------------------------------------------------------------------------- #

sync() {
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
# FS: CLEAN
# Cleaning the file system.
# -------------------------------------------------------------------------------------------------------------------- #

clean() {
  find "${SQL_DST}" -type 'f' -mtime "+${SQL_DAYS:-30}" -print0 | xargs -0 rm -f --
  find "${SQL_DST}" -mindepth 1 -type 'd' -not -name 'lost+found' -empty -delete
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

_id() {
  date -u '+%s'
}

_timestamp() {
  date -u '+%Y-%m-%d.%H-%M-%S'
}

_tree() {
  echo "$( date -u '+%Y' )/$( date -u '+%m' )/$( date -u '+%d' )"
}

_dump() {
  local dbms; dbms="${1%%.*}"
  local db; db="${1##*.}"
  case "${dbms}" in
    'mysql') _mysql "${db}" ;;
    'pgsql') _pgsql "${db}" ;;
    *) _err 'DBMS does not exist!' ;;
  esac
}

_mysql() {
  local db; db="${1}"
  local cmd; cmd='mariadb-dump'; [[ "$( command -v 'mysqldump' )" ]] && cmd='mysqldump'
  "${cmd}" --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-3306}" \
    --user="${SQL_USER:-root}" --password="${SQL_PASS}" --databases="${db}" \
    --single-transaction --skip-lock-tables
}

_pgsql() {
  local db; db="${1}"
  PGPASSWORD="${SQL_PASS}" pg_dump --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-5432}" \
    --username="${SQL_USER:-postgres}" --no-password --dbname="${db}" \
    --clean --if-exists --no-owner --no-privileges --quote-all-identifiers
}

_enc() {
  local out; out="${1}"
  local pass; pass="${ENC_PASS}"
  gpg --batch --passphrase "${pass}" --symmetric --output "${out}" \
    --s2k-cipher-algo "${ENC_S2K_CIPHER:-AES256}" \
    --s2k-digest-algo "${ENC_S2K_DIGEST:-SHA512}" \
    --s2k-count "${ENC_S2K_COUNT:-65536}"
}

_sum() {
  local in; in="${1}"
  local out; out="${in}.sum"
  sha256sum "${in}" | sed 's| .*/|  |g' | tee "${out}" > '/dev/null'
}

_err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2; exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
