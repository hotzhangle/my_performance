#!/usr/bin/env bash
TODAY=`date '+%Y%m%d'`
YESTODAY=`expr $TODAY - 1`
BUILD_TYPE_INDEX=0
REBUILD_COUNT=0

BUILE_TYPE=(user userdebug )
ABS_PATH_OF_PROJECT="/media/code/cmcc/ALPS-MP-N1.MP18-V1_AUS6739_66_N1_INHOUSE/"
MTK_PROJECT_NAME="aus6739_66_n1"
BASE_PROJECT_DIR="out/target/product/"${MTK_PROJECT_NAME}
BASE_TARGET_IMAGE="/media/code/image/daily"

if [[ ! -d ${ABS_PATH_OF_PROJECT} || ! -d ${BASE_PROJECT_DIR} ]]; then
	echo "You must run this script in your Android Project root dir."
	exit
fi

# echo -e "$TODAY\n$YESTODAY"
for dir in `find  ${BASE_TARGET_IMAGE}/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null`
do
	dirname=`basename $dir`;
	if [[ $dirname -lt $YESTODAY ]];then
		rm -rf ${BASE_TARGET_IMAGE}/$dirname
	fi
done

for type in ${BUILE_TYPE[@]}
do
	mkdir -p ${BASE_TARGET_IMAGE}/$YESTODAY/$type/    2>/dev/null
	mkdir -p ${BASE_TARGET_IMAGE}/$TODAY/$type/    2>/dev/null
done

cd ${ABS_PATH_OF_PROJECT}

function moveimage(){
	find ${BASE_PROJECT_DIR}/ -maxdepth 1 -type f  -exec cp  {}  ${BASE_TARGET_IMAGE}/$1/$2/ \;
}

function getLastBuildInfo() {
	last_build_type=`cat ${BASE_PROJECT_DIR}/system/build.prop | grep "ro.build.type" | awk -F '[=]' '{print $2}' | tr [A-Z] [a-z]`
	utc_time=`perl -ne 'if(/ro.build.date.utc=(\d+)/){print "$1"}' ${BASE_PROJECT_DIR}/system/build.prop`
	last_build_date=`date -d @${utc_time} "+%Y%m%d"`
}

function backupImage() {
	getLastBuildInfo
	# if [[ $last_build_date -lt $YESTODAY ]]; then
	# return
	# fi
	# mkdir -p ${BASE_TARGET_IMAGE}/${last_build_date}/${last_build_type}	   2>/dev/null/
	moveimage ${1} $last_build_type
	echo copy image to ${1}/${last_build_type} ok!
}

function buildImage(){
	if [[ $BUILD_TYPE_INDEX -eq 0 && -f ${BASE_PROJECT_DIR}/system/build.prop ]]; then
		backupImage $YESTODAY
		sleep 3
	elif [[ ! -f ${BASE_PROJECT_DIR}/system/build.prop ]]; then
		echo "No build.prop,so last is not a full build." | tee -a build-${1}.log
	fi
	svn cleanup
	svn update .
	# make -j32 clean
	if [[ ${BUILD_TYPE_INDEX} -eq 0 ]];then
		./buildmodem_L05A.sh && source build/envsetup.sh && lunch full_${MTK_PROJECT_NAME}-${1} && make \
			-j32 2>&1 | tee -a  build-${1}.log
	else
		lunch full_${MTK_PROJECT_NAME}-${1} && make -j32 2>&1 | tee -a build-${1}.log
	fi
}

function makeimage(){
	#Invoke function buildImage
	buildImage $1

	result=`tail -2 build-${1}.log | perl -ne 'if(/.*completed.*/){print $_}'`
	if [ -n "$result" ]; then
		let BUILD_TYPE_INDEX+=1
		rm -rf ${BASE_TARGET_IMAGE}/$YESTODAY/$1/
		moveimage $TODAY $1
		return 0
	else
		echo "${TODAY} build of $1 failed , and failed code =  ${result}" | tee  build-${1}.log
		while [[ ${REBUILD_COUNT} -lt 3 ]]; do
			makeimage $1
			let REBUILD_COUNT+=1
		done
		let REBUILD_COUNT=0
		let BUILD_TYPE_INDEX+=1
		return ${BUILD_TYPE_INDEX}
	fi
}

for type in ${BUILE_TYPE[@]}
do
	type=`echo ${type} | tr [A-Z] [a-z]`
	makeimage ${type}
done
