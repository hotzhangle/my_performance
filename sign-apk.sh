#!/usr/bin/env bash

needed_file=(signapk.jar platform.x509.pem platform.pk8)
jarPath=out/host/linux-x86/framework
securityFilePath=build/target/product/security
#for asus path name
securityFilePath_asus=custom/target/product/security/
#arr_length=${#arr_number[*]}或${#arr_number[@]}
needed_file_count=${#needed_file[*]}


echo "###################################"
echo "`date "+%Y-%m-%d %H:%M:%S"`"  #格式化日期字符串，重点要记住用"+"字符来格式化，详细可以man date
echo "you need file ${needed_file[*]}" #输出数组所有元素的值
echo "###################################"
sleep 1s #可以指定时间单位

function showExitMsg(){
	echo file $1 not exist! #$1是指函数调用时携带的第一个参数，以此类推
	sleep 2
	exit 1
}

function getNewPath(){
	if [[ ! -e $1 ]]; then #if语句和逻辑运算符的写法
		if [[ ! -e $2/$1 ]]; then #一般而言，[[]]这种写法的算法最快，time命令可以看程序的执行时间
			showExitMsg $1
		elif [[ -d out/ ]]; then #判断目录是否存在的运算符，还有其他运算符，需要查, -f 文件，-e文件和目录 -s文件存在并且文件size大于0
			echo "存在out目录"
		else
			needed_file[$3] = $2/$1 #为数组某一元素赋值,字符串拼接直接拼接即可，引用字符串变量为了防止出错，尽量采用${}形式
		fi
	fi
}

function checkNeededSignFiles(){
	for (( i = 0; i < $needed_file_count; i++ )); do #for 循环的第一种写法
		case $i in #case 语句的第一种写法
			0 )
				getNewPath ${needed_file[i]} ${jarPath} $i
				;;
			[1-2] ) #这里也可以写成1|2,类似的
				getNewPath ${needed_file[i]} ${securityFilePath} $i
				;;
			* ) #任何情况均会走到这里，此例中我们不处理
				;;
		esac
	done
	unset i #取消变量定义
}

function signAllUnsignedApkCurrentDir(){
	for file in `find . -maxdepth 1 -type f -name "*.apk" | grep -iv signed`; do #for循环的第二种写法
		echo file=${file}
		aname=`echo $file | awk -F'[.\/]' '{print $(NF-1)}' 2>/dev/null`  #2>/dev/null 不显示错误信息 awk命令的简单用法
		sname=`echo $file | sed -e 's#^.*\/##' -e 's@\(.*\)\.apk@\1@'` #sed命令的简单用法，正则表达式的定界符
		echo aname=${aname} sname=${sname}
		java -jar ${needed_file[0]} ${needed_file[1]} ${needed_file[2]} ${aname}.apk ${aname}_signed.apk
		if [[ $? -eq 0 ]]; then #数字的比较只能用 -eq 类的算法  $?表示上一条命令的执行结果
			echo "${sname}.apk--->${sname}_signed.apk"
		else
			echo -e "\033[31mWarning:Can't sign ${sname}.apk \033[0m" #输出带彩色的字体，本例为表示警告的红色
		fi
	done
}



if [[ -e "*_signed_*.apk" ]]; then #说明until循环的用法
	index=1
	until [[ ! -e "*_signed_$index.apk" ]]; do
		let index+=1 #变量自增的第一种用法 index=$(($index+1)) index=$[$index+1]  index=`expr $index + 1`  let index++
	done
fi

if [ $# -gt 0 -a $# -lt 2 ]; then # $#获得当前脚本执行获得的参数---大于0小于2，即一个。也可以写成if [[ $# -gt 0  &&  $# -lt 2 ]].括号的写法有差别
	#[[]] 中可以使用通配符,不需要引号,当使用-a/-o逻辑操作符号时，需要使用单括号
	apkName=$allocateName.apk
elif [ $# -ge 2 -a $# -le 3 ]; then # -le 表示小于等于，-ge表示大于等于，此处表示2或者3，e表示equals
	myvar=2 #为变量赋值的，注意等号前后均不能有空格
	while [[ $myvar -le $# ]]; do #注意while循环的用法
		echo $`expr $myvar`  #利用expr 计算出$myvar对应的变量值，再用echo $n类似的写法输出命令行的第n个变量
		let myvar++
	done
elif [ $# -lt 0  -o $# -gt 3 ]; then
	echo "$0 has support too many arguments on parameters:$@"  # $@可以输出所有命令行参数，在没有被双引号包围的前提下，等同于$*
fi
checkNeededSignFiles
signAllUnsignedApkCurrentDir
