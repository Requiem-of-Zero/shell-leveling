#!/opt/homebrew/bin/bash

SOURCE_DIR=$1
SOURCE_BASE=$(basename "$SOURCE_DIR")

BACKUP_DIR="$HOME/backups"
TSTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$SOURCE_BASE-$TSTAMP.tar.gz"
DESTINATION="$BACKUP_DIR/$ARCHIVE_NAME"

LOG_FILE="$HOME/Library/Logs/automate-backup-error.log"

log_msg(){
  local message="$1"
  local timestamp
  timestamp="[$(date)]"

  echo "$timestamp $message" >> "$LOG_FILE"
  /usr/bin/logger -t BACKUP_LAUNCHD  "$message"
}

log_msg "🔁 Launchd triggered automate-backup.sh"

if [[ -d "$BACKUP_DIR" ]]; then
  log_msg "📁 Backup directory exists"
else
  log_msg "❗ Backup directory not found. Creating..."
  mkdir -p "$BACKUP_DIR"
  log_msg "✅ Created backup directory at $BACKUP_DIR"
fi

log_msg "🚀 Starting backup of $SOURCE_DIR"

if tar -cvzf "$DESTINATION" "$SOURCE_DIR"; then
  log_msg "✅ Backup successful: $DESTINATION"
else
  log_msg "❌ Backup FAILED at $TSTAMP. Check paths and permissions."
  exit 1
fi