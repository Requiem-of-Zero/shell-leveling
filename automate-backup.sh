#!/opt/homebrew/bin/bash

SOURCE_DIR=$1
SOURCE_BASE=$(basename "$SOURCE_DIR")
BACKUP_DIR="$HOME/backups"
TSTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$SOURCE_BASE-$TSTAMP.tar.gz"
DESTINATION=$BACKUP_DIR/$ARCHIVE_NAME

mkdir -p "$BACKUP_DIR"
echo "Created backup folder in $BACKUP_DIR"

echo "Backing up your directory $SOURCE_DIR"
tar -czvf "$DESTINATION" "$SOURCE_DIR"
echo "$SOURCE_DIR backed up into $DESTINATION saved as $ARCHIVE_NAME"