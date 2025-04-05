#!/opt/homebrew/bin/bash

SOURCE_DIR=$1
SOURCE_BASE=$(basename "$SOURCE_DIR")

BACKUP_DIR="$HOME/backups"
TSTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$SOURCE_BASE-$TSTAMP.tar.gz"
DESTINATION="$BACKUP_DIR/$ARCHIVE_NAME"

LOGFILE="$HOME/Library/Logs/backups-launchd.log"

/usr/bin/logger -t BACKUP_CRON "🔁 Cron triggered run-backup.sh at $(date)"

if [[ -d "$BACKUP_DIR" ]]; then
  /usr/bin/logger -t BACKUP_CRON "Directory Found!"
else
  /usr/bin/logger -t BACKUP_CRON "Backup folder not found"
  mkdir -p "$BACKUP_DIR"
  /usr/bin/logger -t BACKUP_CRON "Created backup folder in $BACKUP_DIR"
fi

/usr/bin/logger -t BACKUP_CRON "Starting backup up $SOURCE_DIR"

if tar -cvzf "$DESTINATION" "$SOURCE_DIR"; then
  /usr/bin/logger -t BACKUP_CRON "Backup successful in $BACKUP_DIR"
else
  /usr/bin/logger -t BACKUP_CRON "Backup Failed for $SOURCE_DIR at $TSTAMP. Either the back up directory was not found or the source was not found."
  exit 1
fi