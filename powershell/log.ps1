<# 定义脚本运行的开始时间变量start #>
$start = Get-Date
<# 切换到log所在的目录#> <# alias 可以查询所有命令的别名 #>
cd D:\zhangle\logs;
$path = "D:\zhangle\logs\LogTools\logReport.csv";
<# 如何使用对象的属性和方法#>
$currentPath=$(Get-Location).path;

function exportVirable(){
    if($args.count -eq 0){
        "No argument!"
    }else{
        $args | foreach {
            $($_).getType().name
            $($_)
        }
    }
}

function formatTimeString([string]$timeString){
    <# 脚本也可以使用list，ms打败了我 #>
    <# $global $script $private $local #>
    $private:list= New-Object -TypeName System.Collections.ArrayList;
    $index = 0;
    while($index -lt $timeString.length){
        if($index+2 -gt $timeString.length){break;}
        $temp = $timeString.subString($index,2);
        $list.Add($temp)|out-null;
        $index += 2;
        #$("index="+$index);
    }
    return $([string]::Join(":",$list));
}

function delSameFile([string]$path){
   if (Test-Path $path){
        Remove-Item -Path  $path  -ErrorAction "SilentlyContinue";
        if (!$?){
            echo $path+" :删除文件操作失败";
            break;
        }else{
           $path+": 同名文件删除文件成功!"
        }
    }
}

function getCsvReport([string]$currentPath="D:\zhangle\logs"){
    #exportVirable $currentPath
    <# 这里注意-like的用法#> <# 注意引号里面变量的用法 #> <# {$_.Name -eq "notepad"} #>
    <# 声明一个数组：$array变量定义了所有符合条件的文件 #>
    $array=Get-ChildItem -Path $currentPath | Where-Object {$_.Name -like "2017*.rar"} | ForEach-Object {"$($_.name)"};
    <# 定义一个模式 #>
    $pattern = "(2017-[01]\d-[0-3]\d)-(\b\w+\b)-(.*)-(\d{6})\.rar";
    <# 判断一个对象是否是数组用 数组名 -is [array] #>
    <# 对于任何一个对象都可以使用Format-List * 查看它所有的属性和方法 #>
    $results=@();
    $index=0;
    foreach ($File in $array)
    {
        <#$File -match $pattern 如果想保持大小写不敏感，使用cmatch #>
        <# $matches  匹配结果会保存在这个变量中 #>
        if ($File -match $pattern){
            <# powershell的函数会把所有的输出作为函数的返回值，这点和bash shell类似 #>
            $timeStr=formatTimeString $matches[4];
            $table=@{
                        "date"=$matches[1];
                        "sn"=$matches[2];
                        "decr"=$matches[3];
                        "time"=$timeStr;
                        "full_time"=$matches[1]+" "+$timeStr
                     };
            $pstable = New-Object -TypeName PSObject -Prop $table;
            $results += $pstable;      
        }
        <# 看看是如何使用echo 命令的，转义符使用`字符，不是像其他语言使用\字符 #>
        $index += 1;
        <# 启用tab键作为分隔符 `t #>
        <# 这里的分隔符不能用tab，否则Select-Object -Property 会把全部内容理解为一个对象 #>
        echo `<............$index............`>
    }
    $results | Export-Csv -Delimiter "," -Encoding UTF8  $path;
    Rename-Item  $path  $(-join($path,'.old'))
    Import-Csv -path  $(-join($path,'.old')) | sort full_time | Export-CSV -UseCulture -NoTypeInformation -Encoding UTF8 -Path $Path;
    delSameFile $(-join($path,'.old'))
    <# 如果是tab作为分隔符，使用`t，而不是\t；这里使用了一个选项UseCulture用来确保CSV文件中的分隔符和你当前系统中安装的Excel版本匹配 #>
    #$header = "date","sn","decr","time";
    <# changeCsvFieldOrder #>
    (Import-CSV -Path $path) | Select-Object -Property "date","sn", "decr","time","full_time" | Export-CSV -UseCulture -NoTypeInformation -Encoding UTF8 -Path $Path;
    #return $path <# 注释掉这个return的目的是为了避免在控制台进一步输出了这个path的变量值 #>
}

function transferToExcel([string]$path){
    #exportVirable $path
    <# load into Excel begin #> <# 使用elseif语句 #>
    delSameFile $($path -replace "csv", "xlsx")
    <# 创建application对象 #>
    $excel = New-Object -ComObject Excel.Application;
    <# 设置不可见属性 #>
    $excel.visible = $true;
    <# 创建工作簿对象 #>
    $workbook=$excel.workbooks.open("$path");
    <# 创建工作表对象 #>
    $worksheet=$workbook.worksheets.item(1)
    <# 激活工作表 #>
    $worksheet.activate()
    <# 获取单元格对象 #>
    $range = $worksheet.Cells.select();
    $usedRange = $worksheet.usedRange
    $rangeSorted = $worksheet.range('E:E');
    $xlSummaryAbove = 0
    $xlSortValues = $xlPinYin = 1
    $xlAscending = 1
    $xlDescending = 2
    #[void]$usedRange.sort($rangeSorted, $xlAscending)
    <# 调整行列属性begin #>
    $worksheet.Cells.EntireColumn.AutoFit() |out-null;
    $worksheet.Cells.EntireRow.AutoFit()|out-null;  
    <# 调整行列属性end #>
    <# 回收excel资源begin #>
    <# 禁止消息框弹出 #>
    $excel.DisplayAlerts = $False
    <# 保存工作簿 #>
    $workbook.SaveAs($($path -replace "csv", "xlsx"),51);
    $worksheet.range('A1').select()
    <# $excel.Quit()
    $excel = $null
    [GC]::Collect() #>
    <# 回收excel资源end #>
    <# load into Excel end #> 
    Remove-Item -Path $path  -ErrorAction "SilentlyContinue"
}

<# 使用自定义函数changeCsvFieldOrder和getCsvReport #>
getCsvReport ${currentPath}
<# 使用自定义函数transferToExcel #>
transferToExcel $path
<# 计算脚本的运行耗时长 #>
$end = Get-Date
Write-Host -ForegroundColor Red ('Total Runtime: ' + ($end - $start).TotalSeconds + "秒")