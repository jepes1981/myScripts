#!/bin/env bash

#disable onedrive monitor service, 
#this is to ensure that next reboot/login does not 
#accidentally delete onedrive files if GoogleDriveJeffCruz1981 is not mounted
systemctl --user stop onedrive
systemctl --user disable onedrive

# unmount the drive
rclone unmount ~/GoogleDrive
rclone unmount ~/GoogleDriveJeffCruz1981

#force lazy unmount just to make sure
fusermount -u -z ~/GoogleDrive
fusermount -u -z ~/GoogleDriveJeffCruz1981

