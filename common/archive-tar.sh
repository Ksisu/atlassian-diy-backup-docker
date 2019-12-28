# -------------------------------------------------------------------------------------
# An archive strategy using Tar and Gzip
# -------------------------------------------------------------------------------------

check_command "tar"

function archive_backup {
    check_config_var "APPLICATION_BACKUP_ARCHIVE_ROOT"
    check_config_var "INSTANCE_NAME"
    check_config_var "APPLICATION_BACKUP_ROOT"

    mkdir -p "${APPLICATION_BACKUP_ARCHIVE_ROOT}"
    APPLICATION_BACKUP_ARCHIVE_NAME="${INSTANCE_NAME}-${TIMESTAMP}.tar.gz"
    run tar -czf "${APPLICATION_BACKUP_ARCHIVE_ROOT}/${APPLICATION_BACKUP_ARCHIVE_NAME}" -C "${APPLICATION_BACKUP_ROOT}" .
}

function prepare_restore_archive {
    APPLICATION_BACKUP_ARCHIVE_NAME=$1

    if [ -z "${APPLICATION_BACKUP_ARCHIVE_NAME}" ]; then
        print "Usage: $0 <backup-snapshot>"
        if [ ! -d "${APPLICATION_BACKUP_ARCHIVE_ROOT}" ]; then
            error "'${APPLICATION_BACKUP_ARCHIVE_ROOT}' does not exist!"
        else
            available_backups
        fi
        exit 99
    fi

    if [ ! -f "${APPLICATION_BACKUP_ARCHIVE_ROOT}/${APPLICATION_BACKUP_ARCHIVE_NAME}.tar.gz" ]; then
        error "'${APPLICATION_BACKUP_ARCHIVE_ROOT}/${APPLICATION_BACKUP_ARCHIVE_NAME}.tar.gz' does not exist!"
        available_backups
        exit 99
    fi

    # Setup restore paths
    APPLICATION_RESTORE_ROOT=$(mktemp -d /tmp/bitbucket.diy-restore.XXXXXX)
    APPLICATION_RESTORE_DB="${APPLICATION_RESTORE_ROOT}/bitbucket-db"
    APPLICATION_RESTORE_HOME="${APPLICATION_RESTORE_ROOT}/bitbucket-home"
    APPLICATION_RESTORE_DATA_STORES="${APPLICATION_RESTORE_ROOT}/bitbucket-data-stores"
}

function restore_archive {
    check_config_var "APPLICATION_BACKUP_ARCHIVE_ROOT"
    check_var "APPLICATION_BACKUP_ARCHIVE_NAME"
    check_var "APPLICATION_RESTORE_ROOT"
    run tar -xzf "${APPLICATION_BACKUP_ARCHIVE_ROOT}/${APPLICATION_BACKUP_ARCHIVE_NAME}.tar.gz" -C "${APPLICATION_RESTORE_ROOT}"
}

function cleanup_old_archives {
    # Cleanup of old backups is not currently implemented
    no_op
}

function available_backups {
    check_config_var "APPLICATION_BACKUP_ARCHIVE_ROOT"
    print "Available backups:"
    # Drop the .tar.gz extension, to make it a backup identifier
    ls "${APPLICATION_BACKUP_ARCHIVE_ROOT}" | sed -e 's/\.tar\.gz$//g'
}
