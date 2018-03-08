adb wait-for-device root
adb wait-for-device remount | Out-Null

##################################################################################
#定义多行字符串如下
$projectHomePath=@"
Z:\cmcc\ALPS-MP-N1.MP18-V1_AUS6739_66_N1_INHOUSE\
"@

$deviceTargetRelativeHome=@"
out\target\product\aus6739_66_n1
"@

#$deviceTargetABSHome=-Join($projectHomePath,$deviceTargetRelativeHome)

Set-Location -Path $projectHomePath$deviceTargetRelativeHome

$generationPath=@"
out/target/product/aus6739_66_n1/system/priv-app/SystemUI/SystemUI.apk
"@

<#$generationRootName=$generationPath.Replace($deviceTargetRelativeHome.Replace('\','/'),"")
$generationRootName=$generationRootName.Substring(0,$generationRootName.LastIndexOf('/')+1)
"`$generationRootName = " + $generationRootName #>

$moduleName=$generationPath.Split('/')[-1].Split('.')[-2]

$modulePath=""

$generationPath=$generationPath.Insert(0,$projectHomePath).Replace('/','\')
if($generationPath -match "(.*)($moduleName)(`.\w+)"){
    $modulePath=$Matches[1]
    $moduleName=$Matches[2]
}else {
    Write-Host -ForegroundColor Red ('Can not locate modulePath and will exit')
}

#cd $modulePath
#Z:\cmcc\ALPS-MP-N1.MP18-V1_AUS6739_66_N1_INHOUSE\out\target\product\aus6739_66_n1\system\priv-app\SystemUI\

##################################################################################
Get-ChildItem -Path $modulePath -Recurse | foreach-Object{
    if((Test-Path -PathType Leaf -Path $_.FullName) -and ($_.Name -match "$moduleName`.\w+")){
        $repName=$projectHomePath+$deviceTargetRelativeHome
        $TargetPath=$_.FullName.Replace($repName,"").Replace('\','/')
        $SourcePaht="."+$TargetPath.Replace('/','\')
        #"`$TargetPath" + "= $TargetPath" 
        #"`$SourcePaht" + "= $SourcePaht" 
        adb wait-for-device push $SourcePaht $TargetPath
        sleep -Milliseconds 500
    }
}
adb shell "pgrep system_server | xargs kill"
