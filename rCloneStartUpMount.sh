#!/bin/env bash

echo "$(date "+%d.%m.%Y %T") start of rCloneStartUpMount.sh" | tee -a "/home/jepes/myScripts/customLogs/GoogleDriveJeffCruz1981-check.log"

nohup rclone mount GoogleDrive: ~/GoogleDrive/ --vfs-cache-mode full &>> /home/jepes/myScripts/customLogs/GoogleDriveJeffCruz1981-check.log &


# Make sure onedrive is turned off if previously turned on.
systemctl --user stop onedrive
systemctl --user disable onedrive
nohup rclone mount GoogleDriveJeffCruz1981: ~/GoogleDriveJeffCruz1981/ --vfs-cache-mode full &>> /home/jepes/myScripts/customLogs/GoogleDriveJeffCruz1981-check.log &


# Call the GoogleDriveJeffCruz1981 mount monitoring and that toggles onedrive service depending on mount status.
/home/jepes/myScripts/syncGoogleDriveOneDrive.sh

