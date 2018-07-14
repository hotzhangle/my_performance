$CurrentPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CurrentPath = Get-Location
Set-Location $CurrentPath
$Directory = $CurrentPath
<# 使用给定名称的参数 #>
#param ($Directory)
function phohibitEmptyInput([String]$customStr){
    if([String]::IsNullOrEmpty($customStr)){
        Write-Host "The string is null or empty and will exit!"
        start-sleep 1;exit;
    }
}
#phohibitEmptyInput $Directory

function MakeForm{
    param($FormText,$ButtonText)
    $null = [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $form = New-Object Windows.Forms.Form
    $form.size = New-Object Drawing.Size -Arg 400,80
    $form.StartPosition = "CenterScreen"
    $form.Text = $FormText.toString()
    $textBox = New-Object Windows.Forms.TextBox
    $textBox.Dock = "fill"
    $form.Controls.Add($textBox)
    $button = New-Object Windows.Forms.Button
    $button.Text = $ButtonText
    $button.Dock = "Bottom"
    $button.add_Click(
    {$global:resultText = $textBox.Text;$form.Close()})
    $form.Controls.Add($button)
    [Void]$form.ShowDialog()
}

#cd  $Directory
<# ======================================================== #>
$script:keywordsPattern="(panic|fatal|exception|incorrect|notice)"
function getFileInfo([Collections.ArrayList]$arrayParam){
        $arrayParam | ForEach-Object {
        "name:"+$_.fullname,
        "mode:"+$_.mode
    }
}

function getStandardFileOutput($fileArray){
    if (Test-Path .\result.txt){
        Remove-Item -Path result.txt
    }
   $fileArray | ForEach-Object {
        [Boolean]$fileFlag=$((get-item $_.fullname) -is [IO.fileinfo]);
        if ($fileFlag){
            $matchesContent=Get-Content $_.fullname | select-string -pattern $keywords
            if($matchesContent.count)
            {
                $_.fullname + "：有关键信息" 
                $_.fullname | Out-File -Append result.txt
                <# 和python一样，powershell支持字符串乘法 #>
                "="*150 | Out-File -Append result.txt
                $matchesContent | Out-File -Append result.txt
            }
        }
    }
}

function getUserSpecifiedWord($fileArray){
    if (Test-Path .\SpecifiedSearch.txt){
        Remove-Item .\SpecifiedSearch.txt
    }
    MakeForm -FormText "Which word do you want specified?" -ButtonText "Submit"
    phohibitEmptyInput $global:resultText
    $fileArray | ForEach-Object {
        [Boolean]$fileFlag=$((get-item $_.fullname) -is [IO.fileinfo]);
        if($fileFlag){
            Select-String $_.fullname -Pattern $global:resultText | Out-File -Append SpecifiedSearch.txt
        }
    }
}

function keywordsFilter([string]$keywords=$keywordsPattern,$fileArray){
    if ($global:resultText -eq 1){
        getStandardFileOutput $fileArray
    }elseif ($global:resultText -eq 2){
        getUserSpecifiedWord $fileArray
    }
}

function compressLog(){
    cd ..
    $curDir = Get-Location
    if (Test-Path "C:\Windows\System32\Rar.exe"){
        #rar a "${Directory}.rar" -m5 -s -r -df "${Directory}"
        rar a "${Directory}.rar" -m5 -s -r "${Directory}"
        cd $curDir
    }else{
        echo "Because it doesn't exist winrar and will not compress!"
        Write-Host 'Press Any Key!' -NoNewline
        $null = [Console]::ReadKey('?')
        #exit
    }
}
<# 这里使用了where-object的多条件形式 #>
$array=Get-ChildItem -Recurse | Where-Object {
    $($_.fullname -like "*.log")  -and $((get-item $_.fullname) -is [IO.fileinfo])
}

#getFileInfo $array
MakeForm -FormText "Keywords search:1 or specified word search:2 ?" -ButtonText "Submit"
phohibitEmptyInput $global:resultText
keywordsFilter $keywordsPattern $array
compressLog
Read-Host
