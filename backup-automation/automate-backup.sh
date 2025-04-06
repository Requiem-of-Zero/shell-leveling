#!/opt/homebrew/bin/bash

SOURCE_DIR=$1
SOURCE_BASE=$(basename "$SOURCE_DIR")

BACKUP_DIR="$HOME/backups"
TSTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$SOURCE_BASE-$TSTAMP.tar.gz"
DESTINATION="$BACKUP_DIR/$ARCHIVE_NAME"

MAX_SIZE=50000
LOGS_DIR="$HOME/Library/Logs/automate-backup-logs/"
LOG_FILE="$HOME/Library/Logs/automate-backup-logs/automate-backup-error-recent.log"

log_msg(){
  local message="$1"
  local timestamp
  timestamp="[$(date)]"

  echo "$timestamp $message" >> "$LOG_FILE"
  logger -t BACKUP_LAUNCHD  "$message"
}

rotate_logs(){
  mkdir -p "$LOGS_DIR"
  if [[ -f "$LOG_FILE" ]]; then
    local LOG_SIZE
    LOG_SIZE=$(wc -c < "$LOG_FILE")
    if (( LOG_SIZE >= MAX_SIZE  )); then
      local ROTATED_FILE="$LOGS_DIR/automate-backup-logs-$TSTAMP.log"
      mv "$LOG_FILE" "$ROTATED_FILE"
      touch "$LOG_FILE"
      log_msg "[$(date)] Log roated to $ROTATED_FILE" >> "LOG_FILE"

      local old_logs
      mapfile -t old_logs < <(ls -1t "$LOGS_DIR"/automate-backup-error-*.log 2>/dev/null)
      if (( ${#old_logs[@]} > 5 )); then
        for log in "${old_logs[@]:5}"; do
          rm -f "$log"
          log_msg "[$(date)] Deleted old log: $log"
        done
      fi
    fi
  else
    log_msg "Log file DNE. Creating log file"
    touch "$LOG_FILE"
  fi
}

rotate_logs
log_msg "🔁 Launchd triggered automate-backup.sh"

if [[ -d "$BACKUP_DIR" ]]; then
  log_msg "📁 Backup directory exists"
else
  log_msg "❗ Backup directory not found. Creating..."
  mkdir -p "$BACKUP_DIR"
  log_msg "✅ Created backup directory at $BACKUP_DIR"
fi

log_msg "🚀 Starting backup of $SOURCE_DIR"

if tar -czf "$DESTINATION" "$SOURCE_DIR"; then
  log_msg "✅ Backup successful: $DESTINATION"
else
  log_msg "❌ Backup FAILED at $TSTAMP. Check paths and permissions."
  exit 1
fi