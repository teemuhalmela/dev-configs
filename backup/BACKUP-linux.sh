#!/bin/bash
#
# Backup all the things!
# http://www.mikerubel.org/computers/rsync_snapshots/

BACKUP_DIR=~/backup
BACKUP_NAME=TYOT_LINUX
WORK_DIR=~/TYOT_LINUX
#DESKTOP_DIR=/cygdrive/c/Users/teemu.halmela/Desktop
EXCLUDE_FILE=~/TYOT_LINUX/backup/backup_exclude

readarray includes < "backup_include"
DIRS_TO_BACKUP=( $WORK_DIR ${includes[@]} )

OLDEST_BACKUP=$BACKUP_DIR/$BACKUP_NAME.3
MIDDLE2_BACKUP=$BACKUP_DIR/$BACKUP_NAME.2
MIDDLE1_BACKUP=$BACKUP_DIR/$BACKUP_NAME.1
LATEST_BACKUP=$BACKUP_DIR/$BACKUP_NAME.0



## There are cases when babun hasn't mapped windows dirs properly, so make sure they
## are present.
for i in "${DIRS_TO_BACKUP[@]}"
do
    DIR_ERROR=false
    if [ ! -d $i ] && [ ! -f $i  ]; then
        echo "ERROR: Directory/file $i not found."
        DIR_ERROR=true
    fi
done

if [ "$DIR_ERROR" = true ]; then
    exit 1
fi

## Shift old backups.
if [ -d $OLDEST_BACKUP ]; then
    rm -rf $OLDEST_BACKUP
fi

if [ -d $MIDDLE2_BACKUP ]; then
    mv $MIDDLE2_BACKUP $OLDEST_BACKUP
fi

if [ -d $MIDDLE1_BACKUP ]; then
    mv $MIDDLE1_BACKUP $MIDDLE2_BACKUP
fi

if [ -d $LATEST_BACKUP ]; then
    mv $LATEST_BACKUP $MIDDLE1_BACKUP
fi

## Do a new backup.
rsync -a --delete --delete-excluded --exclude-from="$EXCLUDE_FILE" --link-dest=$MIDDLE1_BACKUP ${DIRS_TO_BACKUP[*]} $LATEST_BACKUP/

# Where there any errors?
if [ $? -ne 0 ]; then
    echo "There were errors! Will not make a zip file."
    exit 1
fi

ZIP=zip

NEW_ZIP=$LATEST_BACKUP.$ZIP

#REMOTE_DIR=~/share/backup
REMOTE_DIR=/media/sf_TYOT/backup
OLDEST_BACKUP_ZIP=$REMOTE_DIR/$BACKUP_NAME.3.$ZIP
MIDDLE2_BACKUP_ZIP=$REMOTE_DIR/$BACKUP_NAME.2.$ZIP
MIDDLE1_BACKUP_ZIP=$REMOTE_DIR/$BACKUP_NAME.1.$ZIP
LATEST_BACKUP_ZIP=$REMOTE_DIR/$BACKUP_NAME.0.$ZIP

# Updates the zip with new changes
zip -q -r -FS $NEW_ZIP $LATEST_BACKUP

if [ ! -d $REMOTE_DIR ]; then
    echo "ERROR: Directory $REMOTE_DIR not found."
    echo "Unable to move zip file to a remote locations."
    echo "Move $NEW_ZIP manually."
    exit 1
fi

if [ -f $OLDEST_BACKUP_ZIP ]; then
    rm $OLDEST_BACKUP_ZIP
fi

if [ -f $MIDDLE2_BACKUP_ZIP ]; then
    mv $MIDDLE2_BACKUP_ZIP $OLDEST_BACKUP_ZIP
fi

if [ -f $MIDDLE1_BACKUP_ZIP ]; then
    mv $MIDDLE1_BACKUP_ZIP $MIDDLE2_BACKUP_ZIP
fi

if [ -f $LATEST_BACKUP_ZIP ]; then
    mv $LATEST_BACKUP_ZIP $MIDDLE1_BACKUP_ZIP
fi

if [ -f $LATEST_BACKUP_ZIP ]; then
    rm $LATEST_BACKUP_ZIP
fi

cp $NEW_ZIP $LATEST_BACKUP_ZIP

WEEKLY_DIR=$REMOTE_DIR/weekly
OLDEST_BACKUP_ZIP_W=$WEEKLY_DIR/$BACKUP_NAME.w.3.$ZIP
MIDDLE2_BACKUP_ZIP_W=$WEEKLY_DIR/$BACKUP_NAME.w.2.$ZIP
MIDDLE1_BACKUP_ZIP_W=$WEEKLY_DIR/$BACKUP_NAME.w.1.$ZIP
LATEST_BACKUP_ZIP_W=$WEEKLY_DIR/$BACKUP_NAME.w.0.$ZIP

if [ ! -d $WEEKLY_DIR ]; then
    echo "Creating $WEEKLY_DIR dir."
    mkdir $WEEKLY_DIR
fi

if [ ! -f $LATEST_BACKUP_ZIP_W ]; then
    echo "First weekly backup."
    cp $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_W
fi

if [ $(find "$LATEST_BACKUP_ZIP_W" -mtime +5) ]; then
    echo "Doing weekly backup."
    if [ -f $OLDEST_BACKUP_ZIP_W ]; then
        rm $OLDEST_BACKUP_ZIP_W
    fi

    if [ -f $MIDDLE2_BACKUP_ZIP_W ]; then
        mv $MIDDLE2_BACKUP_ZIP_W $OLDEST_BACKUP_ZIP_W
    fi

    if [ -f $MIDDLE1_BACKUP_ZIP_W ]; then
        mv $MIDDLE1_BACKUP_ZIP_W $MIDDLE2_BACKUP_ZIP_W
    fi

    if [ -f $LATEST_BACKUP_ZIP_W ]; then
        mv $LATEST_BACKUP_ZIP_W $MIDDLE1_BACKUP_ZIP_W
    fi

    cp $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_W
fi

MONTHLY_DIR=$REMOTE_DIR/monthly
MONTHLY_BACKUP_NAME=$MONTHLY_DIR/$BACKUP_NAME.m
LATEST_BACKUP_ZIP_M=$MONTHLY_BACKUP_NAME.0.$ZIP

if [ ! -d $MONTHLY_DIR ]; then
    echo "Creating $MONTHLY_DIR dir."
    mkdir $MONTHLY_DIR
fi

if [ ! -f $LATEST_BACKUP_ZIP_M ]; then
    echo "First monthly backup."
    cp $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_M
fi

if [ $(find "$LATEST_BACKUP_ZIP_M" -mtime +29) ]; then
    echo "Doing monthly backup."
    if [ -f $MONTHLY_BACKUP_NAME.12.$ZIP ]; then
        rm $MONTHLY_BACKUP_NAME.12.$ZIP
    fi
    for i in $(seq 11 -1 0)
    do
        FROM=$MONTHLY_BACKUP_NAME.$i.$ZIP
        TO=$MONTHLY_BACKUP_NAME.$(($i+1)).$ZIP
        if [ -f $FROM ]; then
            mv $FROM $TO
        fi
    done
    cp $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_M
fi

YEARLY_DIR=$REMOTE_DIR/yearly
YEARLY_BACKUP_NAME=$YEARLY_DIR/$BACKUP_NAME.y
LATEST_BACKUP_ZIP_Y=$YEARLY_BACKUP_NAME.0.$ZIP

if [ ! -d $YEARLY_DIR ]; then
    echo "Creating $YEARLY_DIR dir."
    mkdir $YEARLY_DIR
fi

year=$(date +%Y)
year_backup="$YEARLY_BACKUP_NAME.$year.$ZIP"

if [ ! -f $LATEST_BACKUP_ZIP_Y ]; then
    echo "First yearly backup."
    cp $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_Y
    cp $LATEST_BACKUP_ZIP $year_backup
fi

if [ $(find "$LATEST_BACKUP_ZIP_Y" -mtime +365) ]; then
    echo "Doing yearly backup."
    if [ -f $year_backup ]; then
        echo "Backup $year_backup already exists!"
        exit 1
    fi
    cp $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_Y
    cp $LATEST_BACKUP_ZIP $year_backup
fi

echo "BACKUP DONE!"
