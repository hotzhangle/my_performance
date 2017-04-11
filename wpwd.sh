#!/usr/bin/env bash

function wpwd(){
  local ip=`ifconfig | grep -v "127.0.0.1" | grep -s "inet addr:" | awk -F '[ :]' '{print $13}' `
  if [ $# -eq 0 ]; then
    pwd|sed 's#\/#\\#g' | sed 's#^#\\\\'$ip'#g'
  else
    for arg  in $@
      do
        pwd | sed 's#\/#\\#g' | sed -e 's@^@\\\\'$ip'@g' -e 's@$@\\'$arg'@g'
      done
  fi
  #以下的文件判断关系是用于加在路径后面，防止出现异常的，这个版本还需要完善
  if [ -f $arg ];then
    echo $arg
  elif [ -d $arg ];then
    echo $arg
  else
    continue
  fi
}
