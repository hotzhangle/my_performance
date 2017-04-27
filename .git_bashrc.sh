alias 'cls=clear'
function wcd(){
	#echo $# $1
	if [ $# -ne 1 ];then
		return 1
	else
		local path=`echo $1 | sed -e 's#\\\#\/#g' -e 's#^[A-Z]#\/\l&#' -e 's#:##'g`
		if [ -d $path ];then
			cd $path
		elif [ -f $path ];then
			path=`echo $path | sed -e 's#\(.*\/\)\(.*\)#\1#'`
			echo $path
			wcd $path
		else
			echo -e "\e[1;31mWarning:arguments error.\e[0m"
			return 2
		fi
	fi
}
function wpwd(){
  #local ip=`ifconfig | grep -v "127.0.0.1" | grep -s "inet addr:" | awk -F '[ :]' '{print $13}' `
  local ip=
  if [ $# -eq 0 ]; then
    pwd|sed 's#\/#\\#g' | sed 's#^#\\\\'$ip'#g'
  else
    for arg  in $@
      do
        if [ -f $arg ];then
		    pwd | sed 's#\/#\\#g' | sed -e 's@^@'$ip'@g' -e 's@$@\\'$arg'@g' -e 's#\/#\\#g' -e 's#^\\##' -e 's#\(^[a-z]\)#\u&:#'
        elif [ -d $arg ];then
          pwd | sed 's#\/#\\#g' | sed -e 's@^@'$ip'@g' -e 's@$@\\'$arg'@g' -e 's#^\\##' -e 's#\(^[a-z]\)#\u&:#' -e 's#\/#\\#g'
        else
          continue
        fi        
      done
  fi
}

function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -name out -prune -o -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}

function find_tag(){
    for arg in $(ls .)
     do
         find $arg -type f | xargs grep $@
         echo -e "\e[1;31m *****************************************\e[0m"
         echo -e "\e[1;37m #########################################\e[0m"
         echo -e "\e[1;33m *****************************************\e[0m"
         echo -e "\e[1;32m #########################################\e[0m"
         echo -e "\e[1;34m *****************************************\e[0m"
         echo -e "\e[1;36m #########################################\e[0m"
         echo -e "\e[1;35m *****************************************\e[0m"
         read -p "press any key continue."
     done
}
