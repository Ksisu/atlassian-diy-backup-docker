APPLICATION_HOME=/data/application_home/
APPLICATION_UID=$(stat -c "%u" APPLICATION_HOME)
APPLICATION_GID=$(stat -c "%g" APPLICATION_HOME)

# PostgreSQL configuration
# APPLICATION_DB=confluence FROM ENV VARIABLE
# POSTGRES_HOST=localhost FROM ENV VARIABLE
# POSTGRES_USERNAME=confluence FROM ENV VARIABLE
# export PGPASSWORD=confluence FROM ENV VARIABLE
# POSTGRES_PORT=5432 FROM ENV VARIABLE

# Make use of PostgreSQL 9.3+ options if available
psql_version="$(psql --version | awk '{print $3}')"
psql_majorminor="$(printf "%d%03d" $(echo "${psql_version}" | tr "." "\n" | sed 2q))"
if [[ ${psql_majorminor} -ge 9003 ]]; then
    PG_PARALLEL="-j 5"
    PG_SNAPSHOT_OPT="--no-synchronized-snapshots"
fi

# The path to working folder for the backup
APPLICATION_BACKUP_ROOT=/data/backup_root
APPLICATION_BACKUP_DB=${APPLICATION_BACKUP_ROOT}/db/
APPLICATION_BACKUP_HOME=${APPLICATION_BACKUP_ROOT}/home/

# The path to where the backup archives are stored
APPLICATION_BACKUP_ARCHIVE_ROOT=/data/backup_archive

VERBOSE_BACKUP=true

BACKUP_DISK_TYPE=rsync
BACKUP_DATABASE_TYPE=postgresql
BACKUP_ARCHIVE_TYPE=tar
