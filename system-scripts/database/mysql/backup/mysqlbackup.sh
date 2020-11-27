#!/bin/bash
# MySQL backup script
# mysqlbackup.sh

### System Setup ###
BACKUP=/var/backups/mysql
if [ ! -d $BACKUP ]; then
        echo "Making folder $BACKUP..."
        mkdir -p $BACKUP
fi
NOW=$(date +"%d-%m-%Y")

### MySQL Setup ###
MUSER="root"
MPASS="<PASSS>"
MHOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

### Start MySQL Backup ###
echo -e "Export single database ..."
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
        echo "Salvaguardando ${db}... "
        FILE=$BACKUP/$db.$NOW.sql.gz
        if [ ! -f $FILE ];
        then
                $MYSQLDUMP --single-transaction -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
        else
                echo "dump $FILE already done ..."
        fi
done

echo -e "Export full database ..."
FILE=$BACKUP/salvatotalmysql.$NOW.gz
if [ ! -f $FILE ];
then
        $MYSQLDUMP --all-databases --single-transaction -u $MUSER -h $MHOST -p$MPASS | $GZIP -9 > $FILE
else
        echo dump $FILE already done...
fi

echo -e "Delete older files than 5 days ... "
find $BACKUP -mtime +5 -exec ls -Falh {} \;
find $BACKUP -mtime +5 -exec rm {} \;
