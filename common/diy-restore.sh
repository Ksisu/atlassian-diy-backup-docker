#!/bin/bash
# Ensure the script terminates whenever a required operation encounters an error
set -e

SCRIPT_DIR=$(dirname "$0")
source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/common.sh"
source_archive_strategy
source_database_strategy
source_disk_strategy

# Ensure we know which user:group things should be owned as
if [ -z "${APPLICATION_UID}" -o -z "${APPLICATION_GID}" ]; then
    error "Both APPLICATION_UID and APPLICATION_GID must be set in '${BACKUP_VARS_FILE}'"
fi


##########################################################

# Prepare for restore process
if [ -n "${BACKUP_ARCHIVE_TYPE}" ]; then
    prepare_restore_archive "${1}"
fi

info "Preparing for restore"

prepare_restore_disk "${1}"
prepare_restore_db "${1}"

if [ -n "${BACKUP_ARCHIVE_TYPE}" ]; then
    restore_archive
fi

info "Restoring disk (home directory and data stores) and database"

# Restore the filesystem
restore_disk "${1}"

# Restore the database
restore_db

success "Successfully completed the restore of your instance"

if [ -n "${FINAL_MESSAGE}" ]; then
    echo "${FINAL_MESSAGE}"
fi
