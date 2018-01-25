$LogType="crash"
#$MyInvocation.InvocationName
#$MyInvocation.MyCommand.Path
$currentPath = Split-Path -Paren $MyInvocation.MyCommand.Definition
cd $currentPath
write-host I`'m here:`t $(Get-Location).path
#Start-Sleep -s 3
if (test-path -Path .\Collection) {
    Remove-Item -Path .\Collection -Recurse -Force
}
mkdir .\Collection | Out-Null
Get-ChildItem -Recurse  -Exclude .\Collection | ? {
($_.name -match $LogType) -and  ( Test-Path $_.fullname -PathType leaf )
} | ForEach-Object { 
    Copy-Item -path  $_.fullname  -Destination .\Collection
}

Get-ChildItem -Path .\Collection -Recurse | ForEach-Object {
    $line=get-content   $_.fullname | Measure-Object -line
    if ( $line.lines -le 2){
        write-host $_.fullname line count = $line.lines is too short.
        return
    }
    notepad++.exe $_.fullname
}
