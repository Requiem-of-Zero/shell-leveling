#!/opt/homebrew/bin/bash

SEARCH_PATH=$1
FILE="${2}.txt"

if [ -f "$SEARCH_PATH/$FILE" ]; then
  echo "File exists: $FILE"
else
  echo "File does not exist"
fi