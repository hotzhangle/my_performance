#!/usr/bin/env bash

# function rand(){
# min=$1
# max=$(($2-$min+1))
# num=$(date +%s%N) #man date
# echo $(($num%$max+$min))
# }

# for j in $(seq 1 $1)
# do
# echo $j
# testBtOrWifi
# done

# function testBtOrWifi(){
# rnd=$(rand 1 4)
# usleep 300*1000 #nanosecond
# case $rnd in
# echo $rnd
# 1)
# adb shell "am broadcast -a android.intent.action.CLOSE_BT"
# ;;
# 2)
# adb shell "am broadcast -a android.intent.action.OPEN_BT"
# ;;
# 3)
# adb shell "am broadcast -a android.intent.action.CLOSE_WIFI"
# ;;
# 4)
# adb shell "am broadcast -a android.intent.action.OPEN_WIFI"
# ;;
# *)
# echo "unsupport input option."
# ;;
# esac
# }
magic='--calling-python-from-/bin/sh--'
"""exec" python -E  "$0" "$@" """#$magic"
if __name__ == '__main__':
	import sys
if sys.argv[-1] == '#%s' % magic:
	del sys.argv[-1]

def testBtOrWifi(default=0):
	import random,time,os
	# rnd=random.randint(0,2)
	# print(rnd)
	# sleep 0.3 second
	time.sleep(0.3)
	if (default == 0):
		print "close bluetooth"
		text = os.popen("adb shell 'am broadcast -a android.intent.action.CLOSE_BT'")
		print "close wifi"
		text = os.popen("adb shell 'am broadcast -a android.intent.action.CLOSE_WIFI'")
	elif (default == 1):
		print "open bluetooth"
		text = os.popen("adb shell 'am broadcast -a android.intent.action.OPEN_BT'")
		print "open wifi"
		text = os.popen("adb shell 'am broadcast -a android.intent.action.OPEN_WIFI'")
	else:
		print "can not support argument %s",rnd
	return default

rnd = testBtOrWifi()

def runPressTest():
	# 引用全局变量，不需要golbal声明，修改全局变量，需要使用global声明，特别地，列表、字典等如果只是修改其中元素的值，可以直接使用全局变量，不需要global声明。
	global rnd
	if rnd == 0:
		rnd = 1
	else:
		rnd = 0
	testBtOrWifi(rnd)

print "Now prepare run", sys.argv[1], "times"
for j in range(1,(int(sys.argv[1])+1)):
	runPressTest()
	print(j)
exit(0)
