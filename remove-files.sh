#!/opt/homebrew/bin/bash

FILE_PATH=$1

find "$FILE_PATH" -type f -name "*.txt" > to-be-deleted.txt

find "$FILE_PATH" -type f -name "*.txt" | while IFS= read -r file; do 
  echo "Found: $file"
  rm "$file"
  echo "$file removed"
done
