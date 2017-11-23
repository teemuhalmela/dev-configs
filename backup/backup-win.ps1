
$DRY_RUN=$false
if($DRY_RUN){
    Write-Host "DOING DRY RUN!"
}
$BACKUP_DIR="C:\BACKUP"
$BACKUP_NAME="TYOT"
$WORK_DIR="C:\TYOT"
$DESKTOP_DIR="C:\Users\teemu.halmela\Desktop"

$ZIP7="C:\Program Files\7-Zip/7z.exe"

$ZIP="zip"

$LATEST_BACKUP_ZIP="$BACKUP_DIR\$BACKUP_NAME.0.$ZIP"

if(Test-Path $LATEST_BACKUP_ZIP){
    Write-Host "REMOVING $LATEST_BACKUP_ZIP"
    if(!($DRY_RUN)){
        Remove-Item $LATEST_BACKUP_ZIP
    }
}

& $ZIP7 a -tzip $LATEST_BACKUP_ZIP $WORK_DIR $DESKTOP_DIR

# $REMOTE_DIR="H:\backup"
$REMOTE_DIR="INSERT FINAL BACKUP FOLDER HERE"
$OLDEST_REMOTE_BACKUP_ZIP="$REMOTE_DIR\$BACKUP_NAME.3.$ZIP"
$MIDDLE2_REMOTE_BACKUP_ZIP="$REMOTE_DIR\$BACKUP_NAME.2.$ZIP"
$MIDDLE1_REMOTE_BACKUP_ZIP="$REMOTE_DIR\$BACKUP_NAME.1.$ZIP"
$LATEST_REMOTE_BACKUP_ZIP="$REMOTE_DIR\$BACKUP_NAME.0.$ZIP"

if(!(Test-Path $REMOTE_DIR)){
    Write-Host "ERROR: Directory $REMOTE_DIR not found."
    Write-Host "Unable to move zip file to a remote locations."
    Write-Host "Move $LATEST_BACKUP_ZIP manually."
    exit 1
}

if(Test-Path $OLDEST_REMOTE_BACKUP_ZIP){
    Write-Host "REMOVING $OLDEST_REMOTE_BACKUP_ZIP"
    if(!($DRY_RUN)){
        Remove-Item $OLDEST_REMOTE_BACKUP_ZIP
    }
}

if(Test-Path $MIDDLE2_REMOTE_BACKUP_ZIP){
    Write-Host "MOVING $MIDDLE2_REMOTE_BACKUP_ZIP $OLDEST_REMOTE_BACKUP_ZIP"
    if(!($DRY_RUN)){
        Move-Item $MIDDLE2_REMOTE_BACKUP_ZIP $OLDEST_REMOTE_BACKUP_ZIP
    }
}

if(Test-Path $MIDDLE1_REMOTE_BACKUP_ZIP){
    Write-Host "MOVING $MIDDLE1_REMOTE_BACKUP_ZIP $MIDDLE2_REMOTE_BACKUP_ZIP"
    if(!($DRY_RUN)){
        Move-Item $MIDDLE1_REMOTE_BACKUP_ZIP $MIDDLE2_REMOTE_BACKUP_ZIP
    }
}

if(Test-Path $LATEST_REMOTE_BACKUP_ZIP){
    Write-Host "MOVING $LATEST_REMOTE_BACKUP_ZIP $MIDDLE1_REMOTE_BACKUP_ZIP"
    if(!($DRY_RUN)){
        Move-Item $LATEST_REMOTE_BACKUP_ZIP $MIDDLE1_REMOTE_BACKUP_ZIP
    }
}

Write-Host "COPY $LATEST_BACKUP_ZIP $LATEST_REMOTE_BACKUP_ZIP"
if(!($DRY_RUN)){
    Copy-Item $LATEST_BACKUP_ZIP $LATEST_REMOTE_BACKUP_ZIP
}

$WEEKLY_DIR="$REMOTE_DIR\weekly"
$OLDEST_BACKUP_ZIP_W="$WEEKLY_DIR\$BACKUP_NAME.w.3.$ZIP"
$MIDDLE2_BACKUP_ZIP_W="$WEEKLY_DIR\$BACKUP_NAME.w.2.$ZIP"
$MIDDLE1_BACKUP_ZIP_W="$WEEKLY_DIR\$BACKUP_NAME.w.1.$ZIP"
$LATEST_BACKUP_ZIP_W="$WEEKLY_DIR\$BACKUP_NAME.w.0.$ZIP"

if(!(Test-Path $WEEKLY_DIR)){
    Write-Host "Creating $WEEKLY_DIR dir."
    if(!($DRY_RUN)){
        New-Item $WEEKLY_DIR -type directory
    }
}

if(!(Test-Path $LATEST_BACKUP_ZIP_W)){
    Write-Host "First weekly backup."
    Write-Host "COPY $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_W"
    if(!($DRY_RUN)){
        Copy-Item $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_W
    }
}

$weekDayDiff=((Get-Date) - ((Get-Item $LATEST_BACKUP_ZIP_W).LastWriteTime)).days
Write-Host "WEEKDIFF: $weekDayDiff"

if($weekDayDiff -gt 6){
    Write-Host "Doing weekly backup."
    if(Test-Path $OLDEST_BACKUP_ZIP_W){
        Write-Host "REMOVING $OLDEST_BACKUP_ZIP_W"
        if(!($DRY_RUN)){
            Remove-Item $OLDEST_BACKUP_ZIP_W
        }
    }

    if(Test-Path $MIDDLE2_BACKUP_ZIP_W){
        Write-Host "MOVING $MIDDLE2_BACKUP_ZIP_W $OLDEST_BACKUP_ZIP_W"
        if(!($DRY_RUN)){
            Move-Item $MIDDLE2_BACKUP_ZIP_W $OLDEST_BACKUP_ZIP_W
        }
    }

    if(Test-Path $MIDDLE1_BACKUP_ZIP_W){
        Write-Host "MOVING $MIDDLE1_BACKUP_ZIP_W $MIDDLE2_BACKUP_ZIP_W"
        if(!($DRY_RUN)){
            Move-Item $MIDDLE1_BACKUP_ZIP_W $MIDDLE2_BACKUP_ZIP_W
        }
    }

    if(Test-Path $LATEST_BACKUP_ZIP_W){
        Write-Host $LATEST_BACKUP_ZIP_W $MIDDLE1_BACKUP_ZIP_W
        if(!($DRY_RUN)){
            Move-Item $LATEST_BACKUP_ZIP_W $MIDDLE1_BACKUP_ZIP_W
        }
    }

    Write-Host "COPY $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_W"
    if(!($DRY_RUN)){
        Copy-Item $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_W
    }
}

$MONTHLY_DIR="$REMOTE_DIR\monthly"
$MONTHLY_BACKUP_NAME="$MONTHLY_DIR\$BACKUP_NAME.m"
$LATEST_BACKUP_ZIP_M="$MONTHLY_BACKUP_NAME.0.$ZIP"

if(!(Test-Path $MONTHLY_DIR)){
    Write-Host "Creating $MONTHLY_DIR dir."
    if(!($DRY_RUN)){
        New-Item $MONTHLY_DIR -type directory
    }
}

if(!(Test-Path $LATEST_BACKUP_ZIP_M)){
    Write-Host "First monthly backup."
    Write-Host "COPY $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_M"
    if(!($DRY_RUN)){
        Copy-Item $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_M
    }
}

$monthDiff=((Get-Date) - ((Get-Item $LATEST_BACKUP_ZIP_M).LastWriteTime)).days
Write-Host "MONTHDIFF: $monthDiff"

if($monthDiff -gt 29){
    Write-Host "Doing monthly backup."

    For ($i=11; $i -ge 0; $i--) {
        $FROM="$MONTHLY_BACKUP_NAME.$i.$ZIP"
        $TO="$MONTHLY_BACKUP_NAME.$(($i+1)).$ZIP"
        if(Test-Path $FROM){
            Write-Host "MOVING $FROM $TO"
            if(!($DRY_RUN)){
                Move-Item $FROM $TO
            }
        }
    }
    Write-Host "COPY $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_M"
    if(!($DRY_RUN)){
        Copy-Item $LATEST_BACKUP_ZIP $LATEST_BACKUP_ZIP_M
    }
}

Read-Host -Prompt "Press Enter to continue"
