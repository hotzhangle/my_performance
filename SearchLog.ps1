cd  "E:\android_log\7-13_732C_google app has stop\HAOM4XL6\mtklog\mobilelog"

#=============================================================================================================
$script:LOG_NAME="Test"
$script:Log_Type_Array = @("*events*")#, "*main*")#,"*kernel*")
write-host "LogType="$Log_Type_Array

#$script:log_level="[VDIWEFS]"
$script:log_level="[IWE]"

$script:Exclude_Word=
#$script:Exclude_Word="TestGPS|bluetooth|wifi|mic|sensor|FactoryItemManager"
write-host "Exclude_Word = "$script:Exclude_Word
if([String]::IsNullOrEmpty($script:Exclude_Word)){
    Write-Host "The Exclude_Word is null"
    [bool]$script:enable_Exclude= $false
}else{
    [bool]$script:enable_Exclude= $true
}

$script:TAG="am_create_activity"
#$script:TAG="\w+"

#$script:search_pid="1485"
$script:search_pid="\d{1,}"

$script:relation_operator="-ge"
$script:relation_operator=$null
$date_str_pattern="(\d\d-\d\d)"
$time_str_pattern="(\d\d:\d\d:\d\d.\d{1,6})"
$custom_appointed_time="01-01 00:15:12.650"

$script:Search_Pattern=$date_str_pattern + "\s+" + $time_str_pattern + "\s+"+$log_level+"/\b"+$TAG+"\b\(\s+"+$search_pid+"\):"
if($false){
    $Search_Pattern_Mtklog=$date_str_pattern + "\s+" + $time_str_pattern + "(\s+\d+){2}" + "\s+"+$log_level + "\s+\b"+$TAG+"\b:" + "\s+(.*)"
    $script:Search_Pattern = $Search_Pattern_Mtklog
}

write-host "Search_Pattern = "$Search_Pattern
write-host "enable_Exclude = "$script:enable_Exclude
$Seperator_line = "=" * 30
write-host $Seperator_line$Seperator_line
#=============================================================================================================

$script:fileName=".\temp\"+ $LOG_NAME + ".log"

if  (!(test-path ".\temp\")){mkdir temp}
if (test-path $fileName){Remove-Item -Recurse $fileName}

function GetDateAndTimeStr([String]$LogLine){
    if ($LogLine -match $Search_Pattern){
        $date_str=$matches[1]
        $time_str=$matches[2]
    }else{
        $date_str = $null
        $time_str = $null
    }
    $date_str
    $time_str
}

$script:is_continue = $true
function TimeFilter([String]$LogLine,[String]$time_compare_operator){
    #write-host "LogLine = "$LogLine
    $get_time_temp_arr=GetDateAndTimeStr $LogLine
    #write-host "get_time_temp_arr = "$get_time_temp_arr
    $time_str_temp=$get_time_temp_arr -join " "
    #write-host "time_str_temp = "$time_str_temp
    
    $command_express = $time_str_temp,$time_compare_operator,$custom_appointed_time -join " "
    
    if ($time_compare_operator -eq '-gt'){
        #write-host $time_str_temp "-gt" $custom_appointed_time
        return $time_str_temp -gt $custom_appointed_time
    }elseif($time_compare_operator -eq '-lt'){
        #write-host $time_str_temp "-lt" $custom_appointed_time
        return $time_str_temp -lt $custom_appointed_time
    }elseif($time_compare_operator -eq '-ge'){
        return $time_str_temp -ge $custom_appointed_time
    }elseif($time_compare_operator -eq '-le'){
        return $time_str_temp -le $custom_appointed_time
    }elseif ($time_compare_operator -eq '-eq'){
        return $time_str_temp -eq $custom_appointed_time
    }elseif ($null -eq $time_compare_operator){
        return $false
    }
}

function ExportLogFile([String]$LogLine){
    if ($relation_operator){
        if(TimeFilter $LogLine $relation_operator){$_.line >> $script:fileName;}
    }else{
        $_.line >> $script:fileName;
    }
}

function ExcludeWordOrNot([Collections.ArrayList]$arrayParam){
    $index = 0
    $arrayParam | ForEach-Object {
        #$index
        #if ($index-- -eq 0){write-host "enable_Exclude_Toggle = "$enable_Exclude}
        $_.name
        "`r`n"+ $Seperator_line*2 + $_.name +$Seperator_line*2 + "`r`n" >> $script:fileName
        $private:match_log=Select-String -Path $_.fullname -Pattern $script:Search_Pattern
        if($script:enable_Exclude){
                $private:match_log | ForEach-Object {
                #$bool=$_.line -like "*"+$Exclude_Word+"*"
                $private:bool=$_.line -match $script:Exclude_Word#"*"+$Exclude_Word+"*"
                if(!$private:bool){
                    ExportLogFile $_.line
                }
            }
        }else{
                $private:match_log | ForEach-Object {
                    ExportLogFile $_.line
            }
        } 
    }
}

$array=Get-ChildItem -Recurse -Include  $Log_Type_Array | Sort-Object -Unique
$start = Get-Date
ExcludeWordOrNot $array
$end = Get-Date
Write-Host -ForegroundColor Red ('Total Runtime: ' + ($end - $start).TotalSeconds)
#if(Test-Path $fileName){start $fileName}
if(Test-Path $fileName){Get-Content $fileName | Out-GridView}
#夹私货
if (test-path D:\zhangle\zhangle\shareClipboard.pl){
    Remove-Item D:\zhangle\zhangle\shareClipboard.pl
    if (!(test-path D:\zhangle\zhangle\)){mkdir D:\zhangle\zhangle\}
    if (test-path H:\shareClipboard.pl){Copy-Item H:\shareClipboard.pl D:\zhangle\zhangle\}
}
