#==========压缩创建的目录，压缩完成会删除源文件==========
$array=Get-ChildItem -Path $currentPath | Where-Object {$_.Name -like "2017*.rar"} | ForEach-Object {"$($_.name)"};
$pattern = "(2017-[01]\d-[0-3]\d)-(\b\w+\b)-(.*)-(\d{6})";
foreach($File in $array){
    if ($File -match $pattern){
        $tempArray=Get-ChildItem -Recurse | Where-Object {
            if ((get-item $_.fullname) -is [IO.fileinfo]){
                Measure-Object 
            }
        }
    }
}
if (Test-Path -Path "C:\Windows\System32\Rar.exe"){
    rar a "%T%.rar" -m5 -s -r -df "%T%"
}else{
    echo "Because it doesn't exist winrar and will not compress!"
    Read-Host
}