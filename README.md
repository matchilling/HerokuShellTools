# Heroku Shell Tools

Just another collection of some hopefully useful shell scripts for heroku.

## Scripts

- `importAppDatabase.sh`
  - Imports a related heroku postgres database by a given app name and restores it on localhost.
  - Usage example: `importAppDatabase.sh HEROKU_APP_NAME -u LOCAL_DB_USERNAME -db LOCAL_DB_NAME -p LOCAL_DB_PORT`
  - If no backup id is passed via `-bid` a new backup will be created
