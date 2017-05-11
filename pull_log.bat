@echo off
set "Ymd=%date:~,4%%date:~5,2%%date:~8,2%"
set "hh=%time:~0,2%"
if /i %hh% LSS 10 (set "hh=0%time:~1,1%")
set "Time=%hh%%time:~3,2%%time:~6,2%"
set /p SN=input your phone SN:
set /p DECR=input description about this log:
set T=%Ymd%%Time%-%SN%-%DECR%
md %T%
cd %T%
@echo this notes created by scripts.Please echo following messages >> ./ReadMe.txt
@echo 1.brief description. >> ./ReadMe.txt
@echo 2.occur rate. >> ./ReadMe.txt
@echo 3.how to repeat this issue. >> ./ReadMe.txt
@echo 4.which operation have been done before this issue.  >> ./ReadMe.txt
@echo 5.how many devices of this type have been found.  >> ./ReadMe.txt
@echo desc    rate    condition    operation    quantities    >> ./ReadMe.txt
rem adb wait-for-devices
rem adb shell "getprop | grep gsm.serial"  >> ./ReadMe.txt
rem adb shell "find /sdcard/mtklog -maxdepth 1"  | findstr /v  mdlog  > fileList.txt
rem adb pull /sdcard/mtklog/  ./mtklog
rem adb pull /sdcard/mtklog/aee_exp  ./mtklog/aee_exp
rem adb pull /sdcard/mtklog/netlog  ./mtklog/netlog
rem adb pull /sdcard/mtklog/mobilelog  ./mtklog/mobilelog/
rem use /v to filt not match string,there is modemlog
for /f "skip=1 tokens=1" %%i in (E:\study\fileList.txt) do (
	echo adb pull %%i ./mtklog
)
pause
rem ==========抓取指定log==========
adb pull /sdcard/hq_logcat/  ./hq_logcat/
rem 主供的ITO数据
adb pull /sdcard/Rawdata/ ./CtpLog
rem 二供的ITO数据
adb pull sdcard/Android/data/com.focaltech.ft_terminal_test/files/ ./CtpLog
adb pull /data/anr ./hq_logcat/anr
adb pull /sdcard/Pictures/Screenshots/  ./ScreenShots
adb shell "du sdcard/mtklog/mobilelog"  >> ./FileSize.txt
@rem size.ps1需要放在和这个脚本同级的目录下，size.ps1需要指定一个路径参数，本例中用.\mtklog\mobilelog来指代路径
adb shell "du sdcard/mtklog/mobilelog"  >> ./FileSize.txt
powershell ..\size.ps1 .\mtklog\mobilelog\  >> ./FileSize.txt
adb kill-server
cd ..
rem ==========压缩创建的目录，压缩完成会删除源文件==========
rem 将winrar安装目录下的rar.exe,unrar.exe复制到windows目录下就可以使用rar命令了
rar a %T%.rar -m5 -s -r -df %T%
exit 0
