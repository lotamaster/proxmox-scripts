#!/bin/bash

# Usage
# ./mongodb_gdrive_backup.sh <GDRIVE_FOLDER_ID> <SERVICE_ACCOUNT_FILE_NAME> <PREVIOUS_BACKUPS_TO_KEEP> <DB_HOST> <DB_NAME>

GDRIVE_FOLDER_ID=$1
SERVICE_ACCOUNT=$2
PREVIOUS_BACKUPS_TO_KEEP=$3
DB_HOST=$4
DB_NAME=$5

if [ "$#" -ne 5 ]; then
  echo "Incorrect number of arguments." >&2
  exit 1
fi

echo "Checking for files in Google Drive folder: $GDRIVE_FOLDER_ID"
DRIVE_QUERY="'$GDRIVE_FOLDER_ID' in parents"
FILE_LIST=$(gdrive --service-account "$SERVICE_ACCOUNT" list --query "$DRIVE_QUERY" --order "createdTime" --no-header)

if [ -z "$FILE_LIST" ]; then
  NUM_FILES=0
else
  NUM_FILES=$(echo -n "$FILE_LIST" | grep -c .)
fi

if [ "$NUM_FILES" -gt "$PREVIOUS_BACKUPS_TO_KEEP" ]; then
  NUM_TO_DELETE=$((NUM_FILES - PREVIOUS_BACKUPS_TO_KEEP))
  echo "Found $NUM_FILES files. Deleting the $NUM_TO_DELETE oldest file(s) to leave $PREVIOUS_BACKUPS_TO_KEEP previous backups."
  FILES_TO_DELETE=$(echo "$FILE_LIST" | head -n "$NUM_TO_DELETE")

  echo "$FILES_TO_DELETE" | while IFS= read -r line; do
    FILE_ID=$(echo "$line" | awk '{print $1}')

    if [ -n "$FILE_ID" ]; then
      echo "Deleting file with ID: $FILE_ID"
      gdrive --service-account "$SERVICE_ACCOUNT" delete "$FILE_ID"
    fi
  done

  echo "Deletion of outdated backups complete."
else
  echo "Found $NUM_FILES file(s). No deletion of outdated backups necessary."
fi

echo "Dumping MongoDB database..."
FILE_NAME="$DB_NAME"_backup_$(date +%Y-%m-%d_%H-%M-%S).gz
mongodump --host "$DB_HOST" --archive="$FILE_NAME" --gzip --db "$DB_NAME"

echo "Uploading MongoDB database to Google Drive..."
gdrive --service-account "$SERVICE_ACCOUNT" upload --parent "$GDRIVE_FOLDER_ID" "$FILE_NAME"

echo "Removing local dump file..."
rm "$FILE_NAME"

echo "Backup complete."
