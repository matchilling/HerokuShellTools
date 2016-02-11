#!/bin/bash
# -----------------------------------------------------------------------------
# Imports a related heroku postgres database by a given app name and restores
# it on localhost.
#  - Usage example: `importAppDatabase.sh HEROKU_APP_NAME -u LOCAL_DB_USERNAME
#                    -db LOCAL_DB_NAME -p LOCAL_DB_PORT`
#  - If no backup id is passed via `-bid` a new backup will be created
# -----------------------------------------------------------------------------

readonly COLOR_RESET='\x1b[0m'
readonly RED='\x1b[31m'
readonly GREEN='\x1b[32m'
readonly DUMP_FILENAME='latest.dump'
readonly HEROKU_APP_NAME=$1

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -bid|--backup-id)
    readonly BACKUP_ID="$2"
    shift
    ;;
    -p|--port)
    readonly PORT="$2"
    shift
    ;;
    -u|--username)
    readonly USERNAME="$2"
    shift
    ;;
    -db|--dbname)
    readonly DBNAME="$2"
    shift
    ;;
esac
shift
done

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

print_with_color() {
  echo -e "$2[`timestamp`] $1$COLOR_RESET"
}

validate_dependency() {
  command -v $1 > /dev/null 2>&1 ||
    { print_with_color "The program '$1' is currently not installed, exit script." $RED >&2; exit 1; }
}

validate_dependency curl
validate_dependency heroku
validate_dependency pg_restore
validate_dependency rm

print_with_color "Job started ..." $GREEN

if [ $BACKUP_ID ]; then
  print_with_color "Fetching backup '$BACKUP_ID' from heroku" $GREEN
  curl -o $DUMP_FILENAME `heroku pg:backups public-url $BACKUP_ID --app $HEROKU_APP_NAME` --silent
else
  print_with_color "Creating new db dump" $GREEN
  heroku pg:backups capture --app $HEROKU_APP_NAME --quite
  curl -o $DUMP_FILENAME `heroku pg:backups public-url --app $HEROKU_APP_NAME` --silent
fi

print_with_color "Restoring to $DBNAME on $HOST" $GREEN
if [ $PORT ]; then
  pg_restore --clean --no-acl --no-owner -h localhost -U $USERNAME -d $DBNAME -p $PORT $DUMP_FILENAME
else
  pg_restore --clean --no-acl --no-owner -h localhost -U $USERNAME -d $DBNAME $DUMP_FILENAME
fi

rm $DUMP_FILENAME

print_with_color "Import completed successfully" $GREEN
