#!/bin/bash
clear

if [ "$1" == "reset" ]; then
  rm $PWD/.pt_installed
fi

revision=16

# Download the platform-tools only: http://www.hariadi.org/android/manually-download-of-android-sdk-tools-and-sdk-platform-tools/
if [ ! -f "$PWD/.pt_installed" ]; then
  url=http://dl.google.com/android/repository
  if [ `uname -s` == "Darwin" ]; then
    echo "Downloading Android Platform-Tools for Darwin (OSX)"
    wget -q -O - $url/platform-tools_r${revision}-macosx.zip > platform-tools_r${revision}-macosx.zip
    unzip -q -o $PWD/platform-tools_r${revision}-macosx.zip
    echo Done
  else
    echo "Downloading Android Platform-Tools for Linux (GNU)"
    wget -q -O - $url/platform-tools_r${revision}-linux.zip > platform-tools_r${revision}-linux.zip
    unzip -q -o $PWD/platform-tools_r${revision}-linux.zip
    echo Done
  fi
  ANDROID_SDK_HOME=$PWD/platform-tools
  echo "$ANDROID_SDK_HOME" > $PWD/.pt_installed
  rm *.zip
fi

if [ -z "$ANDROID_SDK_HOME" ]; then
  echo ANDROID_SDK_HOME environment variable is not set
  echo Using local "$PWD/.pt_installed" file to set variable
  SDK_HOME=`cat $PWD/.pt_installed`
  echo
else
  SDK_HOME=$ANDROID_SDK_HOME
  echo
fi

PATH=$SDK_HOME:$PATH

# init
function pause()
{
  echo
  read -p "$*"
  echo
}

function install_recovery_root_gapps()
{
  clear
  echo Starting ADB Server
  adb kill-server 
  adb start-server
  echo Make sure device is connected and then
  pause 'Press [Enter] key to continue...'
  echo Waiting for device....
  echo If stuck here drivers are not installed
  adb wait-for-device 
  echo Rebooting device
  adb reboot-bootloader
  echo Press enter when you see text on the screen after Nabi logo
  echo If stuck here drivers are not installed
  pause 'Press [Enter] key to continue...'
  fastboot flash recovery $PWD/files/recovery.img  
  echo Now hit VOL + button on device
  echo Then hit VOL - until Recovery Kernel is selected
  echo Push VOL + to select
  echo Press enter when recovery has booted
  pause 'Press [Enter] key to continue...'
  echo Pushing gapps and root -- This will take a few minutes
  adb push $PWD/files/gapps.zip /sdcard/gapps.zip  
  adb push $PWD/files/gapps-openrecoveryscript /cache/recovery/openrecoveryscript  
  echo Rebooting recovery to flash gapps and root rom.
  adb reboot recovery  
  echo Please wait until install has been completed
  echo Once it has completed hit enter
  pause 'Press [Enter] key to continue...'
  clear
}

function install_only_recovery_root() 
{
  clear
  echo Starting ADB Server
  adb kill-server 
  adb start-server 
  echo Make sure device is connected and then
  pause 'Press [Enter] key to continue...'
  echo Waiting for device....
  echo If stuck here drivers are not installed
  adb wait-for-device 
  echo Rebooting device
  adb reboot-bootloader  
  echo Press enter when you see text on the screen after Nabi logo
  echo If stuck here drivers are not installed
  pause 'Press [Enter] key to continue...'
  fastboot flash recovery $PWD/files/recovery.img  
  echo Now hit VOL + button on device
  echo Then hit VOL - until Recovery Kernel is selected
  echo Push VOL + to select
  echo Press enter when recovery has booted
  pause 'Press [Enter] key to continue...'
  echo Pushing rooted rom -- This will take a few minutes
  adb push $PWD/files/root.zip /sdcard/root.zip  
  adb push $PWD/files/root-openrecoveryscript /cache/recovery/openrecoveryscript  
  echo Rebooting recovery to backup current rom and install root.  No data will be lost
  adb reboot recovery  
  echo Please wait until backup and install have completed
  echo Once it has completed hit enter
  pause 'Press [Enter] key to continue...'
  clear
}

function install_original_recovery()
{
  clear
  echo Starting ADB Server
  adb kill-server 
  adb start-server
  echo Make sure device is connected and then
  pause 'Press [Enter] key to continue...'
  echo Waiting for device....
  echo If stuck here drivers are not installed
  adb wait-for-device 
  echo Rebooting device
  adb reboot-bootloader
  fastboot flash recovery $PWD/files/nabi2_original_recovery.img
  echo Rebooting recovery.
  adb reboot recovery  
  echo Once it has completed hit enter
  clear
}

echo Nabi Recovery Installer
echo TWRP 2.3.3.0 by aicjofs 
echo For Nabi 2
echo Credits: jmztaylor, Theplattypus, Dees_troy, t499user, aicjofs
echo Script by nandub and based on jmztaylor and t499user original work for windows and linux respectively.
echo Script adapted from http://forum.xda-developers.com/showthread.php?t=2016463
echo
var=1
until [ $var -eq 4 ] 
do
  echo "All options will NOT wipe data.  All data is retained"
  echo
  echo "1. Install recovery, root and gapps"
  echo "2. Install only recovery and root"
  echo "3. Install original recovery"
  echo "4. Exit"
  echo
  read -p "Choose an option " var
  if [ "$var" = "1" ]; then
    install_recovery_root_gapps
  fi
  if [ "$var" = "2" ]; then
    install_only_recovery_root
  fi
  if [ "$var" = "3" ]; then
    install_original_recovery
  fi
  if [ "$var" = "4" ]; then
    exit 0
  fi
done
