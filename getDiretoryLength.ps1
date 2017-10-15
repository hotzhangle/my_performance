function filesize ([string]$filepath)  
{  $private:list= New-Object -TypeName System.Collections.ArrayList;
    if ($filepath -eq $null)  
    {  
        throw "路径不能为空"  
    }  
    $_.name + "文件夹  大小(MB)" -f $l | Out-File ($filepath+"test.txt")  
    dir -Path $filepath  -Force -ErrorAction SilentlyContinue |  
    ForEach-Object -Process {
        $dirObject="" | Select-Object -Property Name,size
        if ($_.psiscontainer -eq $true)  
        {#文件夹大小  
            $length = 0  
            dir -Path $_.fullname -Recurse -ErrorAction SilentlyContinue | ForEach-Object{  
                $length += $_.Length  
            }  
            $l = $length/1MB
            # 输出在控制台  
            #$_.name + "文件夹的大小为： {0:n2} MB" -f $l  
            # 写入TXT文件  
            #$_.name + " {0:n2}" -f $l | Out-File -Append ($filepath+"test.txt")  
            $dirObject.name=$_.fullname
            $dirObject.size=$length/1MB
            $list.Add($dirObject)|out-null;
        }else  
        {#文件大小  
            $length = 0  
            dir -Path $_.fullname -Recurse -ErrorAction SilentlyContinue| ForEach-Object{  
                $length += $_.Length  
            }  
            $l = $length/1MB  
            #$_.name + "文件的大小为： {0:n2} MB" -f $l
            #$_.name + " {0:n2}" -f $l | Out-File -Append ($filepath+"test.txt")
            $dirObject.name=$_.fullname
            $dirObject.size=$length/1MB
            $list.Add($dirObject)|out-null;
        }  
    }
    $list | Where-Object {!$_.size -eq 0}|Sort-Object -Property size -Descending 
}  
filesize -filepath "C:\Program Files"

<#$targetPath="C:\Users\22003304"
$directories=Get-ChildItem $targetPath  -Force |where {$_.mode -like "d*"}
$private:list= New-Object -TypeName System.Collections.ArrayList;
foreach ($directory in $directories){
    $dirObject="" | Select-Object -Property Name,size
    $files=(Get-ChildItem $directory.fullname -Recurse -Force -ErrorAction SilentlyContinue|where {$_.mode -like "-a*"})
    foreach ($file in $files){
        $size=$size+$file.length
    }
    $dirObject.name=$directory.fullname
    $dirObject.size=$size/1GB
    $list.Add($dirObject)|out-null;
    #write-host "the size of $directory is : $size MB"
} #>
#$list | Sort-Object -Property size -Descending 
<# $rootDirectory = "C:\Users\22003304" 
 
$colItems = (Get-ChildItem $rootDirectory  | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
foreach ($i in $colItems)
    {
        $subFolderItems = (Get-ChildItem $i.FullName  -Recurse| Measure-Object -property length -sum)
        $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
    } #>
