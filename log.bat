@echo off & color 3d & mode con cols=76 lines=42 & title AutoPullLogWindow
set rr="HKCU\Console\%%SystemRoot%%_system32_cmd.exe"
reg add %rr% /v "WindowPosition" /t REG_DWORD /d 0x000002D2 /f>nul
setlocal enabledelayedexpansion
rem ==========��ȡ��ǰ������ʱ�����==========
call :getDateTimeString
rem ==========��ȡ��ǰ�豸��SN�ź�log������==========
call :getSerialNumber
call :getLogDescription
rem ==========��ȡĿ¼�����ı���==========
::Ŀ¼�м���������ʱ�����ڿ��Ա���Ŀ¼�����ظ�
set T=%Ymd%-%SN%-%DECR%-%Time%
rem ==========����Ŀ¼������Ŀ¼==========
call :setLogDirEnv
rem ==========����Log�������ļ�==========
call :writeReadMeFile
rem ==========�ȴ��豸����==========
adb wait-for-device
rem ==========ץȡָ��log==========
call :getCeilManufacturer  rem ��Ҳ��֪�������Ƕ��Ϊʲô����д������
call :collectLogFile
rem ==========ֹͣadb server==========
adb kill-server
rem ==========�����ϼ�Ŀ¼�����ܻص�log�ĸ�Ŀ¼λ��============
cd ..
rem ==========ѹ��logĿ¼============
call :compressLog
rem ==========ִ��log�����ű�============
::start /b powershell.exe -file "D:\zhangle\logs\LogTools\AutoAnalysisLog.ps1" -Directory "%curScriptPath%2017-08-16-V7081404533-�忨��״̬����ʾ��Ӫ����Ϣ���˽�ͼ-103005"
rem ==========�˳�CMD����=============
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

::func ����豸�����кţ�����û�û���������кţ���Ĭ�ϻ�ȡ��������к�
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
	rem ������ITO����
	::adb pull /sdcard/Rawdata/ ./CtpLog
	rem ������ITO����
	::adb pull sdcard/Android/data/com.focaltech.ft_terminal_test/files/ ./CtpLog

	::judge logfile quality
	::adb shell "du sdcard/mtklog/mobilelog"  >> ./FileSize.txt
	@rem size.ps1��Ҫ���ں�����ű�ͬ����Ŀ¼�£�size.ps1��Ҫָ��һ��·����������������.\mtklog\mobilelog��ָ��·��
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
::����Ƕ�׵Ľ���call����

:compressLog
rem ==========ѹ��������Ŀ¼��ѹ����ɻ�ɾ��Դ�ļ�==========
if exist "C:\Windows\System32\Rar.exe" (
	rar a "%T%.rar" -m5 -s -r -df "%T%"
) else (
	echo "Because it doesn't exist winrar and will not compress!"
	pause
)
GOTO :EOF

