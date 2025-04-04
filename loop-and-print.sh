#!/opt/homebrew/bin/bash

FILE_PATH=$1

if [[ -f "$FILE_PATH" ]]; then
  echo "Reading from file..."

  while IFS= read -r line; do
    echo "File: $line"
  done < "$FILE_PATH"

elif [[ ! -d "$FILE_PATH" ]]; then
  echo "File path not found"
  exit 1
else
  echo "File path found!"
  for file in "$FILE_PATH"/*; do
    echo "File found: $file"
  done
fi