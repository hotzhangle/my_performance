#!/bin/sh
#######################################################################################
	input="nothing have input" #将要获取的项目名称
	branch="love" #变量名和等号之间不能有空格，这可能和你熟悉的所有编程语言都不一样
	maketime=21 #决定是否编译的时间
	CodePath="CodePath"
	BranchName="zhangle"
	Time="`date '+%H%M%S'`"
	arg=$1
#######################################################################################

	function getProjectName (){
		source ~/.bashrc
		echo "----------------------------------"
		echo "please enter your choise:"
		echo "(0) 1580"
		echo "(1) 806"
		echo "(2) 816"
		echo "(3) 700"
		echo "(4) 1518"
		echo "(5) 1519"
		echo "(6) 732"
		echo "(9) Exit Menu"
		echo "----------------------------------"
		read inputProjectName
		input=$inputProjectName
	}

	function getCodePathAndBranchName(){
		echo "You have selected ${input}"
		if [[ $input = 1580 ]]; then
			CodePath="`date '+%m%d'`_letv_dev"
		elif [[ $input = 1518 || $input = 1519 ]]; then
			CodePath="`date '+%m%d'`_meizu_"$input
		elif [[ $input = 732 ]]; then
			CodePath="`date '+%m%d'`_lenovo_"$input
		else
			CodePath="`date '+%m%d'`_asus_"$input
		fi
		echo "BranchName==>$BranchName:CodePath==>$CodePath" #输出分支名称
	}

	function copyMakeShell(){
		cp /media/cc4c9275-a744-43fa-ab89-a65928dbdcc1/zhangle/study/shell/makeCode .
		chmod 777 makeCode
	}

	function makeletv(){
		hh=`date '+%H'`
		if [ $hh -gt $maketime ]
		then
		    echo "$hh behind $maketime"		#CURTIME=`date +"%Y-%m-%d %H:%M:%S"` #当前的系统时间
			source build/envsetup.sh	#执行编译的脚本命令
			lunch full_s2_plus-eng		#选择对应的版本
			carrier open			#该代码对应的参数默认
			make -j24 2>&1 | tee build.log  #执行编译并定向输出编译日志
			make_hq 2>&1 | tee modemBuild.log #
		else
		    echo "$hh in front of $maketime ,will not make"
		    echo "source build/envsetup.sh && lunch full_s2_plus-eng && carrier open && make -j24 2>&1 | tee build.log"
		fi
	}

	function makemeizu(){
		hh=`date '+%H'`
		if [ $hh -gt $maketime ]
		then
		    echo "$hh behind $maketime"		#CURTIME=`date +"%Y-%m-%d %H:%M:%S"` #当前的系统时间
			source build/envsetup.sh	#执行编译的脚本命令
			echo "will make "$1
			case $1 in
				1518 )
				lunch full_hq6755_66_b1a_l-eng		#选择对应的版本
					;;
				1519 )
				lunch full_hq6755_66c_1ma_m-eng		#1519
					;;
				*	 )
			esac
			make -j24 2>&1 | tee build.log  #执行编译并定向输出编译日志

		else
		    echo "$hh in front of $maketime ,will not make"
		    echo "source build/envsetup.sh && lunch full_s2_plus-eng && carrier open && make -j24 2>&1 | tee build.log"
		fi
	}

	function pushletv(){
		# repoletv init -u dianar:mt6797_64_m/platform/manifest.git -b master -m letv/MTK_MASTER.xml --repo-url=dianar:tools/repo.git && repoletv sync && repoletv start mtk_master --all #master branch
		repoletv init -u dianar:mt6797_64_m/platform/manifest.git -b master -m letv/BELMONT_DEV_BSP.xml --repo-url=dianar:tools/repo.git #执行初始化命令
		repoletv sync	#sync代码
		repo start "$BranchName" --all  #创建分支
		echo "BranchName==>$BranchName" #输出分支名称
		copyMakeShell
	}

	function pushasus(){
		echo $1
		case $1 in
			806 )
			branch=mt6580_aosp_aw806_mp
				;;
			816 )
			branch=mt6580_aosp_trunk
				;;
			700 )
			branch=mt6580_aosp_aw700_mp
				;;
			*	)
		esac
		cmdClone="git clone git@192.168.128.206:huaqin/mt6580_aosp_b1a $branch -b $branch"
		echo ${cmdClone}
		eval $cmdClone
		#######################################################################################
		sleep 2
		copyMakeShell
		mv makeCode $branch
		cd $branch
	}

	function pushmeizu(){
		case $1 in
			1518 )
			repo init --no-repo-verify -u ssh://22003304@192.168.130.181:29418/manifest -m al1518_bsp.xml
				;;
			1519 )
			repo init --no-repo-verify -u ssh://22003304@192.168.130.181:29418/manifest -m al1519_bsp.xml
				;;
			*	 )
		esac
		repo sync
		repo start "$BranchName" --all  #创建分支
		echo "BranchName==>$BranchName" #输出分支名称
		copyMakeShell
	}

	function pushlenovo732(){
		repo init --no-repo-verify -u ssh://22003304@192.168.130.181:29418/manifest -m BD1SW3_HQ6735_65T_B1A_M_DEV_al732_br_factory.xml
		repo sync -j32
		repo start "$BranchName" --all  #创建分支
		echo "BranchName==>$BranchName" #输出分支名称
		copyMakeShell
	}

	function makelenovo732(){
		./mk  hq6735m_35u_b1a_m al732row[latam_ds] new
	}

	function makeasus (){
		read -p "Please select which image do you want build,0 exit and 1 eng and 2 user " image;
		#./mk -o=TARGET_BUILD_inputIANT=user hq6580_we_b1a_l aw816[default] new  #user
		cmdEng="./mk hq6580_we_b1a_l aw"$1"[default] new"
		cmdUser="./mk -o=TARGET_BUILD_inputIANT=user hq6580_we_b1a_l aw"$1"[default] new"  #user
		hh=`date '+%H'`
		if [ $hh -gt $maketime ]
		then
		    echo "$hh behind $maketime"
		    case $image in
		    	0 )
		    		exit 0
		    		;;
		    	1 )
		    		eval $cmdEng
		    		;;
		    	2 )
		    		eval $cmdUser
		    		;;
		    esac

		else
		    echo "$hh in front of $maketime ,will not make"
		    echo $cmdEng
		    echo $cmdUser
		fi
	}


	function havaNoSameDirectory(){
		mkdir "$CodePath" #创建目标文件
		cd $CodePath #进入该目录
			if [[ $input == 1580 ]]; then
				pushletv
				makeletv
			elif [[ $input == 1518 || $input == 1519 ]]; then
				pushmeizu $input
				makemeizu $input
			elif [[ $input == 732 ]]; then
				pushlenovo732
				makelenovo732
			elif [[ $input == 806 || $input == 816 || $input == 700 ]]; then
				pushasus $input
				makeasus $input
			else
				echo "非法项目名称"
				sleep 2
				cd ..
				rm -rf "$CodePath"
				exit 0
			fi
	}

	function havaSameDirectory(){
		echo "$CodePath file already exists,can not create!!" #提示文件已存在
		read -p "0 will be delete and 1 exit then press return:" KEY
		case $KEY in
			0) #delete existed file  #选择参数0表示将要删除目录
			chmod 777 "$CodePath" #修改权限
			rm -rf "$CodePath"     #删除目录
			;;
			1)
	            	print_usage
	            	exit 1
	        		;;
				*)
		esac
	}


#######################################################################################
	if [[ ! -n "$arg" ]]; then #检查用户执行脚本的时候是否带有参数
		getProjectName
	else
		input="$arg"
	fi
		getCodePathAndBranchName
	if [ ! -d "$CodePath" ]; then #检查文件是否存在
		havaNoSameDirectory
	else
		havaSameDirectory
	fi
exit 0
