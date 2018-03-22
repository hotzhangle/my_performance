#!/usr/bin/env bash
if [[ x = $1x ]]; then #判断命令行是否有传递参数 $1是指第一个参数，依次类推
	LOG_TYPE=sys_log
else
	LOG_TYPE=$1
fi
if [[ x = $2x ]]; then #判断命令行是否有传递参数 $2是指第一个参数，依次类推
	LOG_TAG=TestRefMic
else
	LOG_TAG=$2
fi
while getopts "a:bc" arg
	do
	case $arg in
		a)
			echo "a's arg:$OPTARG" #参数存在$OPTARG中
		;;
		b)
			echo "b"
		;;
		c)
			echo "c"
		;;
		?) #当有不认识的参数的时候arg为?
			echo "unknow argument"
			exit 1
	esac
done
echo $LOG_TAG | awk -F '[ \t|]*'  '{if(NF>1){print "the key word contain not only one word,only choose the first word as log tag."}}'
LOG_TAG_FILE=`echo $LOG_TAG | awk -F '[ \t|*.]*'  '{print $1}'`
#echo -e "\033[33m sleep 3 second,print log_tag \033[0m"
word_filter=(
			"mHeadsetHandler --> Current thread"
  			"msg.what=" "sending message to activity"
  			"mMediaRecorder.getMaxAmplitude"
			)
echo LOG_TAG_FILE=$LOG_TAG_FILE
LOG_NAME=`echo "${LOG_TAG_FILE}"_"${LOG_TYPE}" | sed -e 's/\.log$//g' -e 's/_log$//g'`
echo LOG_NAME="$LOG_NAME"
for arg in $(find . -mindepth 1 -type d)
	do
		cd $arg
		rm *${LOG_NAME}_log
		for eachfile in $(find . -type f -iname "*$LOG_TYPE*" | grep -iv "_log")
			do
				echo $eachfile
				cat $eachfile | grep -E -iv "${word_filter[0]}|${word_filter[1]}|${word_filter[2]}|${word_filter[3]}" | grep --color=auto -E -is "${LOG_TAG}" | tee  -a ${LOG_NAME}_log
			done
		cd ..
	done
LIST_ALL_TAG_FILE_COMMAND="find . -name "${LOG_NAME}_log" | xargs wc -l | sort -nr  | grep -iv "总用量" "
eval $LIST_ALL_TAG_FILE_COMMAND | awk -F ' ' '{if($1 == 0){print $2}}' | xargs rm 2>/dev/null
eval $LIST_ALL_TAG_FILE_COMMAND | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | sort -n | xargs wc -l | grep -iv "总用量"
