#!/usr/bin/env bash

function wpwd(){
  local ip=`ifconfig | grep -v "127.0.0.1" | grep -s "inet addr:" | awk -F '[ :]' '{print $13}' `
  if [ $# -eq 0 ]; then
    pwd|sed 's#\/#\\#g' | sed 's#^#\\\\'$ip'#g'
  else
    for arg  in $@
      do
        if [ -f $arg ];then
          pwd | sed 's#\/#\\#g' | sed -e 's@^@\\\\'$ip'@g' -e 's@$@\\'$arg'@g' -e 's#\/#\\#g'
        elif [ -d $arg ];then
          pwd | sed 's#\/#\\#g' | sed -e 's@^@\\\\'$ip'@g' -e 's@$@\\'$arg'@g'
        else
          continue
        fi        
      done
  fi
}
