INSTANCE_NAME=bitbucket
# BITBUCKET_URL=http://localhost:7990 FROM ENV VARIABLE

BITBUCKET_HOME=/data/bitbucket_home/
BITBUCKET_UID=$(stat -c "%u" $BITBUCKET_HOME)
BITBUCKET_GID=$(stat -c "%g" $BITBUCKET_GOME)

BACKUP_DISK_TYPE=rsync
BACKUP_DATABASE_TYPE=postgresql
BACKUP_ARCHIVE_TYPE=tar

# The admin user and password for the Bitbucket instance
# BITBUCKET_BACKUP_USER=admin FROM ENV VARIABLE
# BITBUCKET_BACKUP_PASS=admin FROM ENV VARIABLE

BITBUCKET_BACKUP_EXCLUDE_REPOS=()

# PostgreSQL configuration
# BITBUCKET_DB=bitbucket FROM ENV VARIABLE
# POSTGRES_HOST=localhost FROM ENV VARIABLE
# POSTGRES_USERNAME=bitbucket FROM ENV VARIABLE
# export PGPASSWORD=bitbucket FROM ENV VARIABLE
# POSTGRES_PORT=5432 FROM ENV VARIABLE

# Make use of PostgreSQL 9.3+ options if available
psql_version="$(psql --version | awk '{print $3}')"
psql_majorminor="$(printf "%d%03d" $(echo "${psql_version}" | tr "." "\n" | sed 2q))"
if [[ ${psql_majorminor} -ge 9003 ]]; then
    PG_PARALLEL="-j 5"
    PG_SNAPSHOT_OPT="--no-synchronized-snapshots"
fi

# The path to working folder for the backup
BITBUCKET_BACKUP_ROOT=/data/backup_root
BITBUCKET_BACKUP_DB=${BITBUCKET_BACKUP_ROOT}/bitbucket_db/
BITBUCKET_BACKUP_HOME=${BITBUCKET_BACKUP_ROOT}/bitbucket_home/

# The path to where the backup archives are stored
BITBUCKET_BACKUP_ARCHIVE_ROOT=/data/backup_archive

CURL_OPTIONS="-L -s -f"
BITBUCKET_VERBOSE_BACKUP=true

