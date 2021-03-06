$targetLocation="Y:\1526factory\"
$sourceLocation="D:\Log\"
Set-Location $sourceLocation
$date=get-date -Format "MMdd"
$movePattern="[Vv](\d+)-(.*)-\w{4}"+".rar"
$movePattern1="(2017-[01][1-9]-[0-3][0-9])-([Vv]\d+)-(.*)-\d{6}"
$movePattern2="(^0?[1-9]|1[0-2])-([0-3][0-9])-([Vv]\d+)-(.*)"+".zip"
#8-29-v7082800400-听筒声音小并且有杂音.zip
Get-ChildItem | Where-Object {
    [bool]$filter = $_.name -match $movePattern -or $_.name -match $movePattern1 -or $_.name -match $movePattern2
    if ($filter){
        $_.name        
        rar x -ep2 $($sourceLocation + $_.name) $targetLocation  -ErrorAction "SilentlyContinue"
        Move-Item $_ "Y:\log\"
    }
}