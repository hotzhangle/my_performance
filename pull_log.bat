@echo off
rem ==========获取当前的日期时间变量==========
set "Ymd=%date:~,4%%date:~5,2%%date:~8,2%"
set "hh=%time:~0,2%"
if /i %hh% LSS 10 (set "hh=0%time:~1,1%")
set "Time=%hh%%time:~3,2%%time:~6,2%"
rem ==========获取当前设备的SN号和log的描述==========
set /p SN=input your phone SN:
if not defined SN (
	set "SN=1234567890ABCDEF"
)
set /p DECR=input description about this log:
if not defined DECR (
	set "DECR=Description_Is_None"
)
rem ==========获取目录命名的变量==========
set T=%Ymd%%Time%-%SN%-%DECR%
rem ==========创建目录并进入目录==========
md %T%
cd %T%
md CtpLog
rem ==========创建Log的描述文件==========
@echo this notes created by scripts.Please echo following messages >> ./ReadMe.txt
@echo 1.brief description. >> ./ReadMe.txt
@echo 2.occur rate. >> ./ReadMe.txt
@echo 3.how to repeat this issue. >> ./ReadMe.txt
@echo 4.which operation have been done before this issue.  >> ./ReadMe.txt
@echo 5.how many devices of this type have been found.  >> ./ReadMe.txt
@echo desc    rate    condition    operation    quantities    >> ./ReadMe.txt
rem ==========等待设备连接==========
adb wait-for-devices
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
rem ==========停止adb server==========
adb kill-server
rem ==========返回上级目录============
cd ..
rem ==========压缩创建的目录，压缩完成会删除源文件==========
rar a %T%.rar -m5 -s -r -df %T%
move %T% 压缩件
rem ==========退出CMD程序=============
exit 0
