#!/opt/homebrew/bin/bash

SOURCE_DIR=$1
SOURCE_BASE=$(basename "$SOURCE_DIR")

BACKUP_DIR="$HOME/backups"
TSTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$SOURCE_BASE-$TSTAMP.tar.gz"
DESTINATION="$BACKUP_DIR/$ARCHIVE_NAME"

LOGFILE="$HOME/Library/Logs/automate-backup.log"
ERRORLOG="$HOME/Library/Logs/automate-backup-error"

log_msg(){
  local type="$1"
  local message="$2"
  local timestamp="[$(date)]"

  if [[ "$type" == "error" ]]; then
    echo "$timestamp ❌ $message" >> "$ERRORLOG"
    /usr/bin/logger -t BACKUP_LAUNCHD 
  else
    echo "$timestamp $message" >> "$LOGFILE"
    /usr/bin/logger -t BACKUP_LAUNCHD "$message"
  fi
}

log_msg "info" "🔁 Launchd triggered automate-backup.sh"

if [[ -d "$BACKUP_DIR" ]]; then
  log_msg "info" "📁 Backup directory exists"
else
  log_msg "info" "❗ Backup directory not found. Creating..."
  mkdir -p "$BACKUP_DIR"
  log_msg "info" "✅ Created backup directory at $BACKUP_DIR"
fi

log_msg "info" "🚀 Starting backup of $SOURCE_DIR"

if tar -cvzf "$DESTINATION" "$SOURCE_DIR"; then
  log_msg "info" "✅ Backup successful: $DESTINATION"
else
  log_msg "error" "❌ Backup FAILED at $TSTAMP. Check paths and permissions."
  exit 1
fi