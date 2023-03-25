#!/bin/env bash
GDRIVETESTFILE=MountTest.txt
GDRIVENAME=GoogleDriveJeffCruz1981
GDRIVEPATH=/home/jepes/$GDRIVENAME
LOGPATH=/home/jepes/myScripts/customLogs
ONEDRIVESTARTSTOP=1  # 0 - not running, 1 - running
INTERVALCHECK=5 # duration of next attempt to validate. unit is in seconds.

f_Start_OneDrive_Monitor(){
    echo "STARTING ONEDRIVE SERVICE MONITOR"
    systemctl --user enable onedrive
    if [[ $? -eq 0 ]]; then
       systemctl --user start onedrive
       if [[ $? -eq 0 ]]; then
	       echo "$(date "+%d.%m.%Y %T") STARTING ONEDRIVE SERVICE  MONITOR SUCCESS" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
	       ONEDRIVESTARTSTOP=1
       else
	       echo "$(date "+%d.%m.%Y %T") ONEDRIVE SERVICE ENABLED BUT UNABLE TO START" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
       fi
    else
	    echo "$(date "+%d.%m.%Y %T") ONEDRIVE SERVICE MONITOR FAILED: CANNOT ENABLE" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
    fi
}

f_Stop_OneDrive_Monitor(){
    echo "STOPPING ONEDRIVE MONITOR"
    systemctl --user stop onedrive
    if [[ $? -eq 0 ]]; then
       systemctl --user disable onedrive
       if [[ $? -eq 0 ]]; then
	       echo "$(date "+%d.%m.%Y %T") STOPPING ONEDRIVE SERVICE  MONITOR SUCCESS" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
	       ONEDRIVESTARTSTOP=0
       else
	       echo "$(date "+%d.%m.%Y %T") ONEDRIVE SERVICE MONITOR STOPPED BUT UNABLE TO DISABLE" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
       fi
    else
	    echo "$(date "+%d.%m.%Y %T") ONEDRIVE SERVICE MONITOR FAILED: CANNOT STOP" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
    fi
}
# First mount attempt, disable/comment out if mounted seperately
#rclone mount --dry-run --allow-other --acd-templink-threshold 10G --max-read-ahead 1G --no-check-certificate --quiet --stats 0 --retries 3 $GDRIVENAME: $GDRIVEPATH & sleep 5

while :  #start infinite loop
do
if [[ -f "$GDRIVEPATH/$GDRIVETESTFILE" ]]; then
   echo "$(date "+%d.%m.%Y %T") INFO: Check successful, GoogleDriveJeffCruz1981 drive mounted" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
   systemctl --user status onedrive
   if [[ $? -eq 3 ]]; then
	   f_Start_OneDrive_Monitor
   fi
else
   echo "$(date "+%d.%m.%Y %T") ERROR: GoogleDriveJeffCruz1981 Drive not mounted remount in progress" | tee -a "$LOGPATH/$GDRIVENAME-check.log"
   f_Stop_OneDrive_Monitor
   fusermount -u $GDRIVEPATH
   fusermount -u -z $GDRIVEPATH
#  rclone mount \
#	--dry-run \  #	--allow-non-empty \
#	--allow-other \
#	--acd-templink-threshold 10G \
#	--max-read-ahead 4G \
#	--buffer-size 1G \ #	--contimeout 15s \  #	--low-level-retries 1 \
#	--no-check-certificate \
#	--quiet \
#	--stats 0 \
#	--retries 3 \   #	--timeout 30s \
#	$GDRIVENAME:/ $GDRIVEPATH & sleep 5
#   rclone mount --dry-run --allow-other --acd-templink-threshold 10G --max-read-ahead 1G --no-check-certificate --quiet --stats 0 --retries 3 $GDRIVENAME: $GDRIVEPATH & sleep 5
   rclone mount --vfs-cache-mode full  $GDRIVENAME: $GDRIVEPATH & sleep 5
   if [[ -f "$GDRIVEPATH/$GDRIVETESTFILE" ]]; then
      echo "$(date "+%d.%m.%Y %T") INFO: GoogleDriveJeffCruz1981 Remount successful" | tee -a "$LOGPATH/$GDRIVENAME-check.log"

      # Start onedrive monitor
      systemctl --user status onedrive
      if [[ $? -eq 3 ]]; then
	      f_Start_OneDrive_Monitor
      fi
   else
      echo "$(date "+%d.%m.%Y %T") CRITICAL: GoogleDriveJeffCruz1981 Remount failed." | tee -a "$LOGPATH/$GDRIVENAME-check.log"
      f_Stop_OneDrive_Monitor
   fi
fi
echo "DEBUG: sleeping for 1 min/s"; sleep 60; echo "done sleeping"
done
exit
