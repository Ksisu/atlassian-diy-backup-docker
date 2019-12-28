# -------------------------------------------------------------------------
# Common functionality related to clean up lock files in repositories, etc)
# -------------------------------------------------------------------------

BACKUP_VARS_FILE=${BACKUP_VARS_FILE:-"${SCRIPT_DIR}"/backup.vars.sh}
PATH=$PATH:/sbin:/usr/sbin:/usr/local/bin
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# If "psql" is installed, get its version number
if which psql > /dev/null 2>&1; then
    psql_version="$(psql --version | awk '{print $3}')"
    psql_majorminor="$(printf "%d%03d" $(echo "${psql_version}" | tr "." "\n" | sed 2q))"
    psql_major="$(echo ${psql_version} | tr -d '.' | cut -c 1-2)"
fi

if [ -f "${BACKUP_VARS_FILE}" ]; then
    source "${BACKUP_VARS_FILE}"
    debug "Using vars file: '${BACKUP_VARS_FILE}'"
else
    error "'${BACKUP_VARS_FILE}' not found"
fi

# Note that this prefix is used to delete old backups and if set improperly will delete incorrect backups on cleanup.
SNAPSHOT_TAG_PREFIX=${SNAPSHOT_TAG_PREFIX:-${INSTANCE_NAME}-}
SNAPSHOT_TAG_VALUE=${SNAPSHOT_TAG_VALUE:-${SNAPSHOT_TAG_PREFIX}${TIMESTAMP}}


function source_archive_strategy {
    if [[ -e "${SCRIPT_DIR}/archive-${BACKUP_ARCHIVE_TYPE}.sh" ]]; then
        source "${SCRIPT_DIR}/archive-${BACKUP_ARCHIVE_TYPE}.sh"
    else
        # If no archiver was specified, any file system level restore cannot unpack any archives to be restored.
        # Only the "latest snapshot" (i.e., the working folder used by the backup process) is available.
        APPLICATION_RESTORE_DB="${APPLICATION_BACKUP_DB}"
        APPLICATION_RESTORE_HOME="${APPLICATION_BACKUP_HOME}"
        APPLICATION_RESTORE_DATA_STORES="${APPLICATION_BACKUP_DATA_STORES}"
    fi
}

function source_database_strategy {
    if [ -e "${SCRIPT_DIR}/database-${BACKUP_DATABASE_TYPE}.sh" ]; then
        source "${SCRIPT_DIR}/database-${BACKUP_DATABASE_TYPE}.sh"
    else
        error "BACKUP_DATABASE_TYPE=${BACKUP_DATABASE_TYPE} is not implemented, '${SCRIPT_DIR}/database-${BACKUP_DATABASE_TYPE}.sh' does not exist"
        bail "Please update BACKUP_DATABASE_TYPE in '${BACKUP_VARS_FILE}'"
    fi
}

function source_disk_strategy {
    # Fail if it looks like the scripts are being run with an old backup vars file.
    if [ -n "${BACKUP_HOME_TYPE}" ]; then
        error "Configuration is out of date."
        error "Please update the configuration in '${BACKUP_VARS_FILE}'"
        bail "The 'Upgrading' section of the README contains a list of considerations when upgrading."
    fi

    if [ -e "${SCRIPT_DIR}/disk-${BACKUP_DISK_TYPE}.sh" ]; then
        source "${SCRIPT_DIR}/disk-${BACKUP_DISK_TYPE}.sh"
    else
        error "BACKUP_DISK_TYPE=${BACKUP_DISK_TYPE} is not implemented, '${SCRIPT_DIR}/disk-${BACKUP_DISK_TYPE}.sh' does not exist"
        bail "Please update BACKUP_DISK_TYPE in '${BACKUP_VARS_FILE}'"
    fi
}

function source_disaster_recovery_disk_strategy {
    if [ -e "${SCRIPT_DIR}/disk-${STANDBY_DISK_TYPE}.sh" ]; then
        source "${SCRIPT_DIR}/disk-${STANDBY_DISK_TYPE}.sh"
    else
        error "STANDBY_DISK_TYPE=${STANDBY_DISK_TYPE} is not implemented, '${SCRIPT_DIR}/disk-${STANDBY_DISK_TYPE}.sh' does not exist"
        bail "Please update STANDBY_DISK_TYPE in '${BACKUP_VARS_FILE}'"
    fi
}

function source_disaster_recovery_database_strategy {
    if [ -e "${SCRIPT_DIR}/database-${STANDBY_DATABASE_TYPE}.sh" ]; then
        source "${SCRIPT_DIR}/database-${STANDBY_DATABASE_TYPE}.sh"
    else
        error "STANDBY_DATABASE_TYPE=${STANDBY_DATABASE_TYPE} is not implemented, '${SCRIPT_DIR}/database-${STANDBY_DATABASE_TYPE}.sh' does not exist"
        bail "Please update STANDBY_DATABASE_TYPE in '${BACKUP_VARS_FILE}'"
    fi
}

# Freeze the filesystem mounted under the provided directory.
# Note that this function requires password-less SUDO access.
#
# $1 = mount point
#
function freeze_mount_point {
    case ${FILESYSTEM_TYPE} in
    zfs)
        # A ZFS filesystem doesn't require a fsfreeze
        ;;
    *)
        if [ "${FSFREEZE}" = "true" ]; then
            run sudo fsfreeze -f "${1}"
        fi
        ;;
    esac
}

# Unfreeze the filesystem mounted under the provided mount point.
# Note that this function requires password-less SUDO access.
#
# $1 = mount point
#
function unfreeze_mount_point {
    if [ "${FSFREEZE}" = "true" ]; then
        run sudo fsfreeze -u "${1}"
    fi
}

# Add a argument-less callback to the list of cleanup routines.
#
# $1 = a argument-less function
#
function add_cleanup_routine {
    local var="cleanup_queue_${BASH_SUBSHELL}"
    eval ${var}=\"$1 ${!var}\"
    trap run_cleanup EXIT INT ABRT PIPE
}

# Remove a previously registered cleanup callback.
#
# $1 = a argument-less function
#
function remove_cleanup_routine {
    local var="cleanup_queue_${BASH_SUBSHELL}"
    eval ${var}=\"${!var/$1}\"
}

# Execute the callbacks previously registered via "add_cleanup_routine"
function run_cleanup {
    debug "Running cleanup jobs..."
    local var="cleanup_queue_${BASH_SUBSHELL}"
    for cleanup in ${!var}; do
        ${cleanup}
    done
}
