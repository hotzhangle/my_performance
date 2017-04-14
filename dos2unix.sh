#!/usr/bin/env bash

function wcd(){
	#echo $# $1
	if [ $# -ne 1 ];then
		return 2
	else
    #1、按照git_bash的路径格式，转化windows路径格式如D:\Examples\Test成为 /d/Examples/Test
    #2、sed '2s/ /:/g' datafile 将第2行的所有空格替换成为：
    #3、大写转小写:  echo "ABCDS" | sed 's/[A-Z]/\l&/g'   小写转大写: echo "abcds" | sed 's/[a-z]/\u&/g'
    #4、echo 的颜色 重置=0，黑色=30，红色=31，绿色=32，黄色=33，蓝色=34，洋红=35，青色=36，白色=37
		local path=`echo $1 | sed -e 's#\\\#\/#g' -e 's#^[A-Z]#\/\l&#' -e 's#:##'g`
		if [ -d $path ];then
			cd $path
		elif [ -f $path ];then
			path=`echo $path | sed -e 's#\(.*\/\)\(.*\)#\1#'`
			cd $path
		else
			echo -e "\e[1;31mWarning:arguments error.\e[0m"
			return
		fi
	fi
}

function wpwd(){
  local ip=`ifconfig | grep -v "127.0.0.1" | grep -s "inet addr:" | awk -F '[ :]' '{print $13}' `
  if [ $# -eq 0 ]; then
    pwd|sed 's#\/#\\#g' | sed 's#^#\\\\'$ip'#g'
  else
    for arg  in $@
      do
        if [ -f $arg ];then
          #pwd | sed 's#\/#\\#g' | sed -e 's@^@\\\\'$ip'@g' -e 's@$@\\'$arg'@g' -e 's#\/#\\#g'
          pwd | sed 's#\/#\\#g' | sed -e 's@^@'$ip'@g' -e 's@$@\\'$arg'@g' -e 's#\/#\\#g' -e 's#^\\##' -e 's#\(^[a-z]\)#\u&:#'
        elif [ -d $arg ];then
          #pwd | sed 's#\/#\\#g' | sed -e 's@^@\\\\'$ip'@g' -e 's@$@\\'$arg'@g'
	  pwd | sed 's#\/#\\#g' | sed -e 's@^@'$ip'@g' -e 's@$@\\'$arg'@g' -e 's#^\\##' -e 's#\(^[a-z]\)#\u&:#' -e 's#\/#\\#g'
        else
          continue
        fi        
      done
  fi
}
