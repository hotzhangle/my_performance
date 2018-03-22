@echo off & color 3d & mode con cols=76 lines=42 & title AutoPullLogWindow
set rr="HKCU\Console\%%SystemRoot%%_system32_cmd.exe"
reg add %rr% /v "WindowPosition" /t REG_DWORD /d 0x000002D2 /f>nul
setlocal enabledelayedexpansion
rem ==========获取当前的日期时间变量==========
call :getDateTimeString
rem ==========获取当前设备的SN号和log的描述==========
call :getSerialNumber
call :getLogDescription
rem ==========获取目录命名的变量==========
::目录中加上完整的时间日期可以避免目录名称重复
set T=%Ymd%-%SN%-%DECR%-%Time%
rem ==========创建目录并进入目录==========
call :setLogDirEnv
rem ==========创建Log的描述文件==========
call :writeReadMeFile
rem ==========等待设备连接==========
adb wait-for-device
rem ==========抓取指定log==========
call :getCeilManufacturer  rem 我也不知道，这个嵌套为什么总是写不出来
call :collectLogFile
rem ==========停止adb server==========
adb kill-server
rem ==========返回上级目录，才能回到log的根目录位置============
cd ..
rem ==========压缩log目录============
call :compressLog
rem ==========执行log分析脚本============
::start /b powershell.exe -file "D:\zhangle\logs\LogTools\AutoAnalysisLog.ps1" -Directory "%curScriptPath%2017-08-16-V7081404533-插卡后状态栏显示运营商信息附了截图-103005"
rem ==========退出CMD程序=============
goto exit
:exit
	exit 0
GOTO :EOF

:getDateTimeString
	set "Ymd=%date:~,4%-%date:~5,2%-%date:~8,2%"
	set "hh=%time:~0,2%"
	if /i %hh% LSS 10 (set "hh=0%time:~1,1%")
	set Time=%hh%%time:~3,2%%time:~6,2%
	echo Time is= %Time%
GOTO :EOF

::func 获得设备的序列号，如果用户没有输入序列号，则默认获取主板的序列号
:getSerialNumber
	set /p SN=input your phone SN:
	if not defined SN (
		for /F "usebackq delims==" %%a in (`adb wait-for-device shell getprop ro.serialno`) do (
			echo ro.serialno is:%%a
			set SN=%%a
		)
	)
	echo !SN!
GOTO :EOF

:setLogDirEnv
	set curScriptPath=%~dp0
	echo logName is:%T%
	adb wait-for-device shell getprop ro.build.fingerprint
	pause
	md "%T%"
	if %errorlevel% NEQ 0 (
		echo press any key exit window.
		pause
		goto exit
	)

	cd %T%
	md CtpLog
GOTO :EOF

:writeReadMeFile
	@echo %Ymd%	%Time%	%SN%	%DECR% >> ./ReadMe.txt
	@echo this notes created by scripts.Please echo following messages >> ./ReadMe.txt
	@echo 1.brief description. >> ./ReadMe.txt
	@echo 2.occur rate. >> ./ReadMe.txt
	@echo 3.how to repeat this issue. >> ./ReadMe.txt
	@echo 4.which operation have been done before this issue.  >> ./ReadMe.txt
	@echo 5.how many devices of this type have been found.  >> ./ReadMe.txt
	@echo desc    rate    condition    operation    quantities    >> ./ReadMe.txt
GOTO :EOF

:getLogDescription
	set /p DECR=input description about this log:
	if not defined DECR (
		set "DECR=Description_Is_None"
	)
GOTO :EOF

:collectLogFile
	::Log files
	if "Mediatek" == %Manufacturer% (
		::adb pull /sdcard/mtklog/
		::adb pull sdcard/mtklog/mobilelog
	)
	if "QUALCOMM" == "%Manufacturer%" (
		adb pull -p  /sdcard/logs/  ./logs/
		adb pull -p  /sdcard/hq_logcat/  ./hq_logcat/
		adb shell dmesg > dmesg.log
		rem adb pull -p  /sdcard/diag_logs/  ./diag_logs/
	)
	
	adb pull /data/anr ./hq_logcat/anr
	
	::property info	
	adb pull -p  /default.prop  ./logs/default.prop	
	adb pull -p  /system/build.prop  ./logs/build.prop
	adb shell getprop > ./getprop.prop
	adb shell "cat /proc/cmdline" > ./cmdline.txt
	
	::ScreenShots and video
	adb pull -p /sdcard/Screenshots/  ./ScreenShots
	adb pull -p /sdcard/Pictures/ScreenShots  ./ScreenShots
	adb pull /sdcard/DCIM/Camera/$(adb shell "ls /sdcard/DCIM/Camera | tail -n 1" ) ./ScreenShots/last_picture.jpg
	
	::other data
	rem 主供的ITO数据
	::adb pull /sdcard/Rawdata/ ./CtpLog
	rem 二供的ITO数据
	::adb pull sdcard/Android/data/com.focaltech.ft_terminal_test/files/ ./CtpLog

	::judge logfile quality
	::adb shell "du sdcard/mtklog/mobilelog"  >> ./FileSize.txt
	@rem size.ps1需要放在和这个脚本同级的目录下，size.ps1需要指定一个路径参数，本例中用.\mtklog\mobilelog来指代路径
	::adb shell "du sdcard/mtklog/mobilelog"  >> ./FileSize.txt
	::powershell ..\size.ps1 .\mtklog\mobilelog\  >> ./FileSize.txt
GOTO :EOF

:getCeilManufacturer
	for /F "usebackq delims==" %%a in (`adb shell getprop ro.product.cam.manufacturer`) do (
		set Manufacturer=%%a
	)
	
	if not "QUALCOMM" == "%Manufacturer%" (
		if not "Mediatek" == "%Manufacturer%" (
			set /p localManufacturerVariable=input your phone Ceil Manufacturer:
			echo !localManufacturerVariable!
			setx AndroidDeviceCeilManufacturer !localManufacturerVariable!
		) else (
			echo ceil manufacturer is:MTK
		)
	) else (
		echo "ceil manufacturer is:QUALCOMM"
	)
GOTO :EOF
::不能嵌套的进行call命令

:compressLog
rem ==========压缩创建的目录，压缩完成会删除源文件==========
if exist "C:\Windows\System32\Rar.exe" (
	rar a "%T%.rar" -m5 -s -r -df "%T%"
) else (
	echo "Because it doesn't exist winrar and will not compress!"
	pause
)
GOTO :EOF
