#!/usr/bin/env bash

factory_flag_files=(    BT.FLG
                        FT.FLG
                        AT.FLG
                        WF.FLG
                        WA.FLG
                        PCBA.FLG
                        MMI1.FLG
                        MMI2.FLG
                        FULL.FLG
                        RUNIN.FLG
                        RESET.FLG
                        psn.txt
                        csn.txt
                        countrycode.txt
                        )

adb wait-for-devices
adb shell " mkdir -p /persist/flag"
for arg in "${factory_flag_files[@]}";
        do
                txtFile=`echo $arg | grep txt`
                length=`expr length "$txtFile"`
                #echo $length
                if [ $length -gt 0 ];then
                        if [ $arg = "psn.txt" ];then
                                read -p "please input product SN number:" psn
                                adb shell "echo "$psn" >/persist/flag/"$arg
                        elif [ $arg = "csn.txt" ];then
                                read -p "please input customer SN number:" csn
                                adb shell "echo "$csn" >/persist/flag/"$arg
                        elif [ $arg = "countrycode.txt" ];then
                                read -p "please input country code:" countrycode
                                adb shell "echo "$countrycode" >/persist/flag/"$arg
                        fi
                else
                        adb shell "echo P  > /persist/flag/"$arg
                fi
        done

