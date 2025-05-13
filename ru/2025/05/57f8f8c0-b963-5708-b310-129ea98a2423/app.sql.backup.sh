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
SQL_ON="${SQL_ON:?}"; readonly SQL_ON
SQL_TYPE="${SQL_TYPE:?}"; readonly SQL_TYPE
SQL_DATA="${SQL_DATA:?}"; readonly SQL_DATA
SQL_USER="${SQL_USER:?}"; readonly SQL_USER
SQL_PASS="${SQL_PASS:?}"; readonly SQL_PASS
SQL_DB=("${SQL_DB[@]:?}"); readonly SQL_DB
SYNC_ON="${SYNC_ON:?}"; readonly SYNC_ON
SYNC_HOST="${SYNC_HOST:?}"; readonly SYNC_HOST
SYNC_USER="${SYNC_USER:?}"; readonly SYNC_USER
SYNC_PASS="${SYNC_PASS:?}"; readonly SYNC_PASS
SYNC_DST="${SYNC_DST:?}"; readonly SYNC_DST
MAIL_TO="${MAIL_TO:?}"; readonly MAIL_TO

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  (( ! "${SQL_ON}" )) && return 0; sql_backup && sql_remove && fs_sync
}

# -------------------------------------------------------------------------------------------------------------------- #
# SQL: BACKUP
# Creating a database dump.
# -------------------------------------------------------------------------------------------------------------------- #

sql_backup() {
  local id; id="$( _id )"

  for i in "${SQL_DB[@]}"; do
    local ts; ts="$( _timestamp )"
    local file; file="${i}.${id}.${ts}.sql"

    [[ ! -d "${SQL_DATA}" ]] && mkdir -p "${SQL_DATA}"; cd "${SQL_DATA}" || exit 1
    _dump "${i}" "${file}" && _pack "${file}"
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# SQL: REMOVE
# Deleting old database dumps.
# -------------------------------------------------------------------------------------------------------------------- #

sql_remove() {
  find "${SQL_DATA}" -type f -mtime "+${SQL_DAYS:-30}" -print0 | xargs -0 rm -f --
}

# -------------------------------------------------------------------------------------------------------------------- #
# FS: SYNC
# Sending database dumps to remote storage.
# -------------------------------------------------------------------------------------------------------------------- #

fs_sync() {
  (( ! "${SYNC_ON}" )) && return 0; rsync -a --delete --quiet -e "sshpass -p '${SYNC_PASS}' ssh -p ${SYNC_PORT:-22}" \
    "${SQL_DATA}/" "${SYNC_USER:-root}@${SYNC_HOST}:${SYNC_DST}/"
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

_dump() {
  case "${SQL_TYPE}" in
    'mysql') _mysql "${1}" "${2}" ;;
    'pgsql') _pgsql "${1}" "${2}" ;;
    *) echo >&2 'SQL_TYPE does not exist!'; exit 1 ;;
  esac
}

_mysql() {
  local cmd; cmd='mariadb-dump'; [[ "$( command -v 'mysqldump' )" ]] && cmd='mysqldump'
  "${cmd}" --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-3306}" \
    --user="${SQL_USER:-root}" --password="${SQL_PASS}" \
    --single-transaction --skip-lock-tables "${1}" --result-file="${2}"
}

_pgsql() {
  pg_dump --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-5432}" \
    --username="${SQL_USER:-postgres}" --no-password \
    --dbname="${1}" --file="${2}" \
    --clean --if-exists --no-owner --no-privileges --quote-all-identifiers
}

_pack() {
  xz "${1}"
}

_mail() {
  local id; id="#ID:$( hostname -f ):$( dmidecode -s system-uuid )"
  local type; type="#TYPE:BACKUP:${3}"

  printf '%s\n\n-- \n%s\n%s' "${2}" "${id^^}" "${type^^}" | mail -s "${1}" "${MAIL_TO}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
