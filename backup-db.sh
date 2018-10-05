#!/bin/bash -e

clear

### Server Setup ###
#* MySQL login user name *#
MUSER="root";

#* MySQL login PASSWORD name *#
MPASS="Q1";

#* MySQL login HOST name *#
MHOST="localhost";
MPORT="80";


# DO NOT BACKUP these databases
IGNOREDB="
information_schema
performance_schema
mysql
test
"

#* MySQL binaries *#
MYSQL=`which mysql`;
MYSQLDUMP=`which mysqldump`;
GZIP=`which gzip`;

NOW=`date +"%Y-%m"`;
BACKUPDIR="$PWD/$NOW";

# assuming that /nas is mounted via /etc/fstab
if [ ! -d $BACKUPDIR ]; then
  mkdir -p $BACKUPDIR
else
 :
fi

echo "MySQL Admin Password: "
#read -s mysqlpass

# get all database listing
DBS="$(mysql -u $MUSER -p$MPASS -h $MHOST -P $MPORT -Bse 'show databases')"


# SET DATE AND TIME FOR THE FILE
NOW=`date +"d%dh%Hm%Ms%S"`; # day-hour-minute-sec format
# start to dump database one by one
for db in $DBS
do
        DUMP="yes";
        if [ "$IGNOREDB" != "" ]; then
                for i in $IGNOREDB # Store all value of $IGNOREDB ON i
                do
                        if [ "$db" == "$i" ]; then # If result of $DBS(db) is equal to $IGNOREDB(i) then
                                DUMP="NO";         # SET value of DUMP to "no"
                                #echo "$i database is being ignored!";
                        fi
                done
        fi

        if [ "$DUMP" == "yes" ]; then # If value of DUMP is "yes" then backup database
                FILE="$BACKUPDIR/$db.gz";
                echo "BACKING UP $db";
                $MYSQLDUMP --add-drop-database --opt --lock-all-tables -u $MUSER -p$MPASS -h $MHOST -P $MPORT $db | gzip > $FILE
        fi
done
