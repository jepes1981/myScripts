# myScripts
Scripts that I use on my local machine

**Prerequisite:**
*Setup a google drive and onedrive profile using rclone.

**rCloneStartUpMount.sh**
*Attempts to mount rclone drives. 
*Also disable onedrive service prior mounting google drive to ensure that onedrive does not delete it's cloud data.
*calls syncGoogleDriveOneDrive.sh

**syncGoogleDriveOneDrive.sh**
*checks if Google Drive is mounted. If mounted, it then enables onedrive service for it to be able to sync.\
*checks status of mount based on **MountTest.txt** found on the root of the drive. The script will consider the drive unmounted if file is not found.
*disable onedrive service if google drive is not mounted, tried remounting, only enable onedrive if google drive is mounted.

**rCloneLogoffUnmount.sh**
*unmount google drive and disable onedrive service.

**CPU_Temperature_Monitor.py**
*Monitors CPU Temperature and attempt shutdown when prolonged overheating.
