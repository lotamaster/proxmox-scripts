# proxmox-scripts
## Somewhat specific scripts that I use with proxmox.


### `mongodb_gdrive_backup.sh`
Backs up a mongodb database to Google Drive.

#### Usage
```
./mongodb_gdrive_backup.sh <GDRIVE_FOLDER_ID> <SERVICE_ACCOUNT_FILE_NAME> <PREVIOUS_BACKUPS_TO_KEEP> <DB_HOST> <DB_NAME>
```

#### Prereqs
- Create a service account
- In GCP, download a json with key details for the service account
- Share the drive directory with the service account

#### Args
| Arg | Description |
|---|---|
| GDRIVE_FOLDER_ID | Folder ID of the directory in google drive. Can easily be found in the url |
| SERVICE_ACCOUNT_FILE_NAME | Name of the service account json file. After installing gdrive2, the file should be placed in `/root/.gdrive/` |
| PREVIOUS_BACKUPS_TO_KEEP | Number of previous backups to keep. For example, in order to keep 5 backups always, set this to 4 |
| DB_HOST | Location of the database |
| DB_NAME | Name of the database to back up |
