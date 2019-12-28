#!/bin/bash

# Ensure the script terminates whenever a required operation encounters an error
set -e

SCRIPT_DIR=$(dirname "$0")
source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/common.sh"

##########################################################

readonly DB_BACKUP_JOB_NAME="Database backup"
readonly DISK_BACKUP_JOB_NAME="Disk backup"

# Started background jobs
declare -A BG_JOBS
# Successfully completed background jobs
declare -a COMPLETED_BG_JOBS
# Failed background jobs
declare -A FAILED_BG_JOBS

# Run a command in the background and record its PID so we can wait for its completion
function run_in_bg {
    ($1) &
    local PID=$!
    BG_JOBS["$2"]=${PID}
    debug "Started $2 (PID=${PID})"
}

# Wait for all tracked background jobs (i.e. jobs recorded in 'BG_JOBS') to finish. If one or more jobs return a
# non-zero exit code, we log an error for each and return a non-zero value to fail the backup.
function wait_for_bg_jobs {
    for bg_job_name in "${!BG_JOBS[@]}"; do
        local PID=${BG_JOBS[${bg_job_name}]}
        debug "Waiting for ${bg_job_name} (PID=${PID})"
        {
            wait ${PID}
        } &&  {
            debug "${bg_job_name} finished successfully (PID=${PID})"
            COMPLETED_BG_JOBS+=("${bg_job_name}")
        } || {
            FAILED_BG_JOBS["${bg_job_name}"]=$?
        }
    done

    if (( ${#FAILED_BG_JOBS[@]} )); then
        for bg_job_name in "${!FAILED_BG_JOBS[@]}"; do
            error "${bg_job_name} failed with status ${FAILED_BG_JOBS[${bg_job_name}]} (PID=${PID})"
        done
        return 1
    fi
}

# Clean up after a failed backup
function cleanup_incomplete_backup {
    debug "Cleaning up after failed backup"
    for bg_job_name in "${COMPLETED_BG_JOBS[@]}"; do
        case "$bg_job_name" in
            "$DB_BACKUP_JOB_NAME")
                cleanup_incomplete_db_backup ;;
            "$DISK_BACKUP_JOB_NAME")
                cleanup_incomplete_disk_backup ;;
            *)
                error "No cleanup task defined for backup type: $bg_job_name" ;;
        esac
    done
}

##########################################################

