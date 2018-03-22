#!/usr/bin/env bash
echo `pwd`
# ls -al
adb "wait-for-device"
adb remount
adb shell "rm -rf  /sdcard/hq_logcat"
adb shell "rm /system/priv-app/FactoryKitTest/FactoryKitTest.apk"
adb push ./test_config_default.xml /sdcard/
adb push ./FactoryKitTest_signed.apk /system/priv-app/FactoryKitTest/FactoryKitTest.apk
adb reboot bootloader
fastboot flash boot boot.img && fastboot reboot
# adb reboot
function getCurrentWindowClass(){
	#get current window class name
	current_window_class=`adb shell "dumpsys window | grep -i mcurrent | tac | head -1" | sed -e 's#^.*\(com.*\)\/\(.*\)}$#\2#' 2>/dev/null`
	echo $current_window_class
}
adb "wait-for-devices"
echo "wait-for-device" 

while [[ $(getCurrentWindowClass) != "com.android.launcher3.Launcher" ]]; do
	#getCurrentWindowClass
	sleep 10
	adb shell "input keyevent 82 2>/dev/null"
	sleep 2
	adb shell "input keyevent 82 2>/dev/null"
done
adb shell "am start -n com.android.huaqin.factory/com.android.huaqin.factory.ControlCenterActivity" 2>/dev/null
sleep 2
adb shell "input tap 400 300" 2>/dev/null
