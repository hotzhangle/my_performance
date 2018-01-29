cd 'E:\log\'
$seperatorLine="="*80
"I'm here " + $(Get-Location).Path
Write-Output $seperatorLine

$mobilelogArray=Get-ChildItem -Recurse -Force | Where-Object {
    (Test-Path -PathType Container $_.fullname) -and ($_.name -match "mobilelog")
} | Select-Object -Property fullname

$count = 0

#$mobilelogArray
#Write-Output $seperatorLine

$mobilelogArray | ForEach-Object {
    $flag = [bool]$False
    Get-ChildItem -Recurse -Force -Path $_.FullName | ForEach-Object{
        $needRenameFilePattern="(.*[a-zA-Z+])(_+)log(_+)(\d*)(_+)(\d{4}_\d{4}_\d{6})*"
        #([a-zA-Z+])(_+)log(_+)(\d*)(_+)(\d{4}_\d{4}_\d{6})$
        if ((Test-Path -PathType Leaf $_.FullName) -and ($_.fullname -match $needRenameFilePattern)) {
            $flag = $True        
            $newName = $Matches[1]+"_log."+$Matches[4]
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host @("new Name is:",$newName)
        }
    }
    if($flag){
        Write-Output $seperatorLine
    }
}
