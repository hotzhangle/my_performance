#!/usr/bin/env bash
TODAY=`date '+%Y%m%d'`
YESTODAY=`expr $TODAY - 1`
BUILE_TYPE=(userdebug user)
COUNT=0
# echo -e "$TODAY\n$YESTODAY"
for dir in `find  /media/code/image/daily/ -maxdepth 1 -mindepth 1 -type d`
do
	dirname=`basename $dir`;
	if [[ $dirname -lt $YESTODAY ]];then
		rm -rf /media/code/image/daily/$dirname
	fi
done


for type in ${BUILE_TYPE[@]}
do
	mkdir -p /media/code/image/daily/$YESTODAY/$type/    2>/dev/null
	mkdir -p /media/code/image/daily/$TODAY/$type/    2>/dev/null
done

cd /media/code/cmcc/ALPS-MP-N1.MP18-V1_AUS6739_66_N1_INHOUSE/

function moveimage(){
	find out/target/product/aus6739_66_n1/ -maxdepth 1 -type f  -exec mv {}  /media/code/image/daily/$1/$2/ \;
}

function makeimage(){
	moveimage $YESTODAY $1
	svn cleanup
	svn update .
	# make -j32 clean
	if [[ ${COUNT} -eq 0 ]];then
		./buildmodem_L05A.sh && source build/envsetup.sh && lunch full_aus6739_66_n1-${1} && make \
			-j32 2>&1 | tee build-${1}.log
	else
		lunch full_aus6739_66_n1-${1} && make -j32 2>&1 | tee build-${1}.log
	fi

	local result=`tail -2 build-${1}.log | perl -ne 'if(/.*completed.*/){print $_}'`
	if[ -n "$result" ];then
		let COUNT += 1
		rm -rf /media/code/image/daily/$YESTODAY/$1/
		moveimage $TODAY $1
		return 0
	else
		let COUNT = $?
		echo "${TODAY} build of $1 failed , and failed code =  ${COUNT}" | tee build-${1}.log
		return ${COUNT}
	fi
}

for type in ${BUILE_TYPE[@]}
do
	makeimage ${type}
done
