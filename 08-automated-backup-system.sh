#!/bin/bash

if [[ "$1" == '-h' || "$1" == '-help' || "$1" == '--help' ]]; then
    echo "Usage: $0"
    echo "Automated Backup System for Files and Databases."
    echo "System needs a config file. Please clone 08-automated-backup-system.conf config file on github"
    echo "This system uses rclone tool to send a backup file to cloud. You must prepare rclone config file before using cloud backup."
    echo "https://github.com/Ali-Berk/bash-linux-lab"
    exit 0
fi

CONF_FILE="08-automated-backup-system.conf"
if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    echo "ERROR: Config file not found"
    exit 1
fi

TIMESTAMP=$(date '+%Y%m%d_%H%M')
FILE_NAME="backup_${TIMESTAMP}.tar.gz"
if [[ "$BACKUP_TYPE" == 'file' ]]; then
    if [[ ! -e "$SOURCE_TARGET" ]]; then 
        echo "ERROR: Source not found, please update config settings according to the instructions"
        exit 1
    else
        tar -czf "$FILE_NAME" -C "$(dirname "$SOURCE_TARGET")" "$(basename "$SOURCE_TARGET")"
        if [[ "$?" -ne 0 ]]; then
            echo "ERROR: Backup Failed"
            exit 1
        fi
    fi
elif [[ "$BACKUP_TYPE" == 'db' ]]; then
    export MYSQL_PWD="$DB_PASSWORD"
    
    FILE_NAME="db_backup_${TIMESTAMP}.sql.gz"

    if [[ "$SOURCE_TARGET" == 'all' ]]; then
        mysqldump -u "$DB_USER" --all-databases | gzip > "$FILE_NAME"
    else
        mysqldump -u "$DB_USER" "$SOURCE_TARGET" | gzip > "$FILE_NAME"
    fi

    unset MYSQL_PWD

    if [[ "${PIPESTATUS[0]}" -ne 0 ]]; then
        echo "ERROR: Please check config settings"
        rm -f "$FILE_NAME"
        exit 1
    fi
fi

if [[ "$ENABLE_SSH" == 'true' ]]; then
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "mkdir -p $SSH_PATH"

    if [[ $? -eq 0 ]]; then
        scp -P "$SSH_PORT" "$FILE_NAME" "${SSH_USER}@${SSH_HOST}:${SSH_PATH}/"

        if [[ $? -eq 0 ]]; then
            echo "SSH transfer successful."
        else
            echo "ERROR: SSH transfer failed."
        fi
    else
        echo "ERROR: Failed to connect to the server"
    fi
fi

if [[ "$ENABLE_CLOUD" == 'true' ]]; then
    if ! command -v rclone &> /dev/null; then
        echo "WARNING: rclone is not installed. Cloud transfer skipped."
    else
        if ! rclone listremotes | grep -q "^${CLOUD_REMOTE%%:*}:"; then
            echo "WARNING: rclone config not prepare please run $0 -h"
        else
            rclone copy "$FILE_NAME" "$CLOUD_REMOTE" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "CLOUD transfer successful."
                CLOUD='fine'
            else
                echo "ERROR: Cloud transfer failed."
            fi
        fi
    fi
fi

if [[ -n "$EXPIRE_DAY" ]]; then
    find . -maxdepth 1 -type f \( -name "*.tar.gz" -o -name "*.sql.gz" \) -mtime +"$EXPIRE_DAY" -delete
    if [[ $? -eq 0 ]]; then
        echo "Local backups cleared (older than $EXPIRE_DAY days)"
    else
        echo "ERROR: Local not cleared"
    fi

    if [[ "$ENABLE_SSH" == 'true' ]]; then
        ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "find $SSH_PATH -maxdepth 1 -type f \( -name '*.tar.gz' -o -name '*.sql.gz' \) -mtime +$EXPIRE_DAY -delete"
        if [[ $? -eq 0 ]]; then
            echo "Remote server cleared (older than $EXPIRE_DAY days)"
        else
            echo "ERROR: Remote server not cleared."
        fi
    fi

    if [[ -n "$CLOUD" ]]; then
        rclone delete "$CLOUD_REMOTE" --min-age "${EXPIRE_DAY}d" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "Cloud cleared (older than $EXPIRE_DAY days)"
        else
            echo "ERROR: Cloud not cleared."
        fi
    fi
else
        echo "ERROR: EXPIRE_DAY not defined."
fi