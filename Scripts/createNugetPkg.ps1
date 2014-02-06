$version=$args[0]
$Workspace=$args[1]
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

Write-Host $dir
function truncate-string([string]$value, [int]$length)
{
    if ($value.Length -gt $length) { $value.Substring(0, $length) }
    else { $value }
}

#$timeStr =  $(get-date -f yyMMddHHmmss)
#$hostStr = $env:computername
$versionStr =  "-Stage"

$versionStr = $version + $versionStr
Write-Host "Building version: ", $versiodirnStr


Push-Location $workspace\IntuitMarketWeb\CRESCENDO\Services\build
Remove-Item *.nupkg -recurse
Remove-Item D:\Nuget\builds\*.nupkg
#Create service package 

#copy C:\Program Files (x86)\Jenkins\workspace\Build_CI_Services_Test\smendiratta\Services\bin\Services.dll

.\nuget  pack .\Services.nuspec -Version $versionStr
Write-Host "Build of Services successful"
Write-Host "WORKSPACE is $workspace"

.\nuget  pack .\QuestUI.nuspec -Version $versionStr
Write-Host "Build of Quest UI successful"

.\nuget push *.nupkg -s http://nuget.intuit.com/
Write-Host "Nuget push of Services and Quest UI successful"

#NuGet.exe list -s http://nuget.intuit.com/nuget
 Move-Item *.nupkg D:\Nuget\builds\
Pop-Location
Write-Host "Build and deploy of Services and Quest UI successful"