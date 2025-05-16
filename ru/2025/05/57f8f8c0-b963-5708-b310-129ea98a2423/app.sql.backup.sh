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
SQL_DATA="${SQL_DATA:?}"; readonly SQL_DATA
SQL_USER="${SQL_USER:?}"; readonly SQL_USER
SQL_PASS="${SQL_PASS:?}"; readonly SQL_PASS
SQL_DB=("${SQL_DB[@]:?}"); readonly SQL_DB
SYNC_ON="${SYNC_ON:?}"; readonly SYNC_ON
SYNC_HOST="${SYNC_HOST:?}"; readonly SYNC_HOST
SYNC_USER="${SYNC_USER:?}"; readonly SYNC_USER
SYNC_PASS="${SYNC_PASS:?}"; readonly SYNC_PASS
SYNC_DST="${SYNC_DST:?}"; readonly SYNC_DST
SYNC_DEL="${SYNC_DEL:?}"; readonly SYNC_DEL
SYNC_RSF="${SYNC_RSF:?}"; readonly SYNC_RSF
SYNC_PED="${SYNC_PED:?}"; readonly SYNC_PED
SYNC_CVS="${SYNC_CVS:?}"; readonly SYNC_CVS
SUM_ON="${SUM_ON:?}"; readonly SUM_ON
ENC_ON="${ENC_ON:?}"; readonly ENC_ON
ENC_PASS="${ENC_PASS:?}"; readonly ENC_PASS
MAIL_ON="${MAIL_ON:?}"; readonly MAIL_ON
MAIL_TO="${MAIL_TO:?}"; readonly MAIL_TO

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

run() {
  (( ! "${SQL_ON}" )) && return 0
  sql_remove && sql_backup && fs_sync
}

# -------------------------------------------------------------------------------------------------------------------- #
# SQL: REMOVE
# Deleting old database dumps.
# -------------------------------------------------------------------------------------------------------------------- #

sql_remove() {
  find "${SQL_DATA}" -type 'f' -mtime "+${SQL_DAYS:-30}" -print0 | xargs -0 rm -f --
  find "${SQL_DATA}" -type 'd' -empty -delete
}

# -------------------------------------------------------------------------------------------------------------------- #
# SQL: BACKUP
# Creating a database dump.
# -------------------------------------------------------------------------------------------------------------------- #

sql_backup() {
  local id; id="$( _id )"
  for i in "${SQL_DB[@]}"; do
    local ts; ts="$( _timestamp )"
    local dir; dir="${SQL_DATA}/$( _dir )"
    local file; file="${i}.${id}.${ts}.sql"
    [[ ! -d "${dir}" ]] && mkdir -p "${dir}"; cd "${dir}" || exit 1
    _dump "${i}" "${file}" && _pack "${file}" && _enc "${file}" "${ENC_PASS}" && _sum "${file}" \
      && _mail "$( hostname -f ) / SQL: ${i}" "The '${i}' database is saved in the file '${file}'!" 'SUCCESS'
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# FS: SYNC
# Sending database dumps to remote storage.
# -------------------------------------------------------------------------------------------------------------------- #

fs_sync() {
  (( ! "${SYNC_ON}" )) && return 0
  local opts; opts=('--archive' '--quiet')
  (( "${SYNC_DEL}" )) && opts+=('--delete')
  (( "${SYNC_RSF}" )) && opts+=('--remove-source-files')
  (( "${SYNC_PED}" )) && opts+=('--prune-empty-dirs')
  (( "${SYNC_CVS}" )) && opts+=('--cvs-exclude')
  rsync "${opts[@]}" -e "sshpass -p '${SYNC_PASS}' ssh -p ${SYNC_PORT:-22}" \
    "${SQL_DATA}/" "${SYNC_USER:-root}@${SYNC_HOST}:${SYNC_DST}/" \
    && _mail "$( hostname -f ) / SYNC" 'The database files are synchronized!' 'SUCCESS'
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

_dir() {
  echo "$( date -u '+%Y' )/$( date -u '+%m' )/$( date -u '+%d' )"
}

_dump() {
  local dbms; dbms="${1%%.*}"
  local db; db="${1##*.}"
  local file; file="${2}"
  case "${dbms}" in
    'mysql') _mysql "${db}" "${file}" ;;
    'pgsql') _pgsql "${db}" "${file}" ;;
    *) echo >&2 'DBMS does not exist!'; exit 1 ;;
  esac
}

_mysql() {
  local db; db="${1}"
  local file; file="${2}"
  local cmd; cmd='mariadb-dump'; [[ "$( command -v 'mysqldump' )" ]] && cmd='mysqldump'
  "${cmd}" --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-3306}" \
    --user="${SQL_USER:-root}" --password="${SQL_PASS}" \
    --single-transaction --skip-lock-tables "${db}" --result-file="${file}"
}

_pgsql() {
  local db; db="${1}"
  local file; file="${2}"
  PGPASSWORD="${SQL_PASS}" pg_dump --host="${SQL_HOST:-127.0.0.1}" --port="${SQL_PORT:-5432}" \
    --username="${SQL_USER:-postgres}" --no-password \
    --dbname="${db}" --file="${file}" \
    --clean --if-exists --no-owner --no-privileges --quote-all-identifiers
}

_pack() {
  local file; file="${1}"
  xz "${file}"
}

_enc() {
  (( ! "${ENC_ON}" )) && return 0;
  local in; in="${1}.xz"
  local out; out="${in}.enc"
  local pass; pass="${2}"
  openssl enc -aes-256-cbc -salt -pbkdf2 -in "${in}" -out "${out}" -pass "pass:${pass}" && rm -f "${in}"
}

_sum() {
  (( ! "${SUM_ON}" )) && return 0;
  local in; in="${1}.xz"; (( "${ENC_ON}" )) && in="${1}.xz.enc"
  local out; out="${in}.sum"
  sha256sum "${in}" | sed 's| .*/|  |g' | tee "${out}" > '/dev/null'
}

_mail() {
  (( ! "${MAIL_ON}" )) && return 0;
  local subj; subj="${1}"
  local body; body="${2}"
  local status; status="${3}"
  local id; id="#ID:$( hostname -f ):$( dmidecode -s system-uuid )"
  local type; type="#TYPE:BACKUP:${status}"
  printf '%s\n\n-- \n%s\n%s' "${body}" "${id^^}" "${type^^}" | mail -s "${subj}" "${MAIL_TO}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

run && exit 0 || exit 1
