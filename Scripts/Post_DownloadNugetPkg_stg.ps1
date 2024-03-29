$deploydir="D:\qfnsrv\www\pages\"
$pkg_location="c:\Package_Install\"
$Package_log="$pkg_location\package.log"
$errorflag=0


Function Import-ini([string]$Path = $(Read-Host "Need a Path Parameter"))
{
$ini=@{}
if (Test-Path -Path $Path)
  { 
     switch -regex -file $Path
	  { "^\[(.+)\]$"
	      { 
		     $Category = $matches[1]
		     $ini.$Category=@{}
			}
		"(.+)=(.+)"
		   { 
		     $Key,$Value = $matches[1..2]
			 $ini.$Category.$Key = $Value
		   }		
	}
}
else 
{ 
  Write-Host "File not found - $ini_file"
  }
  $ini
}

$ini_file="$pkg_location\Package_version.ini"
$ini_content=Import-ini -Path $ini_file 
$env_type=$ini_content["Packageid-1"]["env_type"]
$version_pkg=$ini_content["Packageid-1"]["version_pkg"]
$download_status_file="$pkg_location\download_status.$version_pkg.config.temp"
Function Write-log ([string]$msg_type , [string]$log_msg)
{ if (Test-Path -Path $Package_log)
    { 
	try {
	   Add-Content $Package_log  -value "$msg_type-  $log_msg Version=$version_pkg Env=$env_type Node=$env:computername"
	   }
	   catch {
	     Throw "Error:Cannot Append to Log File "
	   }
	   
	}
	else 
	{ 
	 try{
	   New-Item -ItemType file "$Package_log" -Force
	   }
	   catch {
	   Throw "Error:Log File cannot be created"
	   }
	}
}
Function Deploy_SendStatus ([string]$dep_status, [string]$dep_version_pkg)
{

$job_url="http://10.136.221.41/job/Build-Quest-Deploy/buildWithParameters?token=deploy_job&DEP_VERSION=$dep_version_pkg&DEP_STATUS=$dep_status&DEP_HOST=$env:computername"
[net.httpWebRequest] $req = [net.webRequest]::create($job_url)
$req.method = "POST" 
$req.TimeOut = 5000
[net.httpWebResponse] $res = $req.getResponse() 
$resst = $res.getResponseStream() 
$sr = new-object IO.StreamReader($resst) 
$result = $sr.ReadToEnd() 
$sr.close()
$resst.close()
}

if (!(Test-Path "$download_status_file"))
{
    Write-log -msg_type "Fail" -log_msg "Deploy Failed -Packages not Downloaded Properly "
	Deploy_SendStatus -dep_status "FAIL" -dep_version_pkg "$version_pkg"
	Write-Host "Fail:Deploy Failed -Packages not Downloaded Properly "
	 $errorflag=1
	 exit
}
else 
{
   Remove-Item $download_status_file -Recurse
}
if (Test-Path "$pkg_location\IntuitMarket-$env_type\")
{
 try {
Remove-Item "$pkg_location\IntuitMarket-$env_type\" -Recurse
Write-log -msg_type "Info" -log_msg " IntuitMarket-$env_type folder Removed"
}
catch [System.Management.Automation.ActionPreferenceStopException] {

Write-log -msg_type "Error" -log_msg "Cannot Remove IntuitMarket-$env_type folder"

}
} 
New-Item -ItemType directory -Path "$pkg_location\IntuitMarket-$env_type\"

Push-Location $pkg_location

Foreach ( $i in $ini_content.keys )
    { $pkg_id=$ini_content[$i]["pkg_id"]
	  $version_pkg=$ini_content[$i]["version_pkg"]
	 
	  Write-Host " Copying $pkg_id Version - $version_pkg"
	    if ( $pkg_id -match "services")
		{ New-Item -ItemType directory -Path "$pkg_location\IntuitMarket-$env_type\Services\"
		     try {
	      Copy-Item ".\Nuget_pkg\$pkg_id.$version_pkg\WebConfig\stage\Web.config" ".\Nuget_pkg\$pkg_id.$version_pkg\" -Recurse -Force
	       Write-log -msg_type "Info" -log_msg "Web Config Copied"
		  Remove-Item ".\Nuget_pkg\$pkg_id.$version_pkg\WebConfig" -Recurse
		  Remove-Item ".\Nuget_pkg\$pkg_id.$version_pkg\*.nupkg" -Recurse
		   Write-log -msg_type "Info" -log_msg "Nuget Packages deleted for $pkg_id $version_pkg "
		   Copy-Item ".\Nuget_pkg\$pkg_id.$version_pkg\*" "$pkg_location\IntuitMarket-$env_type\Services\" -Recurse -Force
		    Write-log -msg_type "Info" -log_msg "Stage Ready Package for $pkg_id $version_pkg Created "
		}
	catch [System.Management.Automation.ActionPreferenceStopException] {
	Write-log -msg_type "Error" -log_msg "Creating a Stage ready package for $pkg_id $version_pkg failed "
$errorflag=1
}
	}	
		else 
		{
		try {
		
		Remove-Item ".\Nuget_pkg\$pkg_id.$version_pkg\*.nupkg" -Recurse
		 Write-log -msg_type "Info" -log_msg "Nuget Packages deleted for $pkg_id $version_pkg "
		Copy-Item ".\Nuget_pkg\$pkg_id.$version_pkg\*" "$pkg_location\IntuitMarket-$env_type\" -Recurse -Force
		 Write-log -msg_type "Info" -log_msg "Stage Ready Package for $pkg_id $version_pkg Created "
		}
		catch [System.Management.Automation.ActionPreferenceStopException] {

Write-log -msg_type "Error" -log_msg "Creating a Stage ready package for $pkg_id $version_pkg failed "
  $errorflag=1
}
		
		}
		
	  
	  
	}
	 
     Copy-Item ".\Package_version.ini" "$pkg_location\IntuitMarket-$env_type\" -Recurse -Force
	 Write-Host "Copying  Package $version_pkg to $deploydir"
	try {
	 Copy-Item "$pkg_location\IntuitMarket-$env_type\*" "$deploydir" -Recurse -Force
	Write-log -msg_type "Info" -log_msg " Created Packge Deployed to $deploydir"
	
	 }
	 catch [System.Management.Automation.ActionPreferenceStopException] {

Write-log -msg_type "Error" -log_msg "Creating a Stage ready package for $pkg_id $version_pkg failed "
  $errorflag=1
}
Pop-Location


if( $errorflag -ne 0)
{ Write-log -msg_type "Fail" -log_msg "Deploy to $deploydir Faile d"
}
else
{
Write-Host "reseting IIS"
Write-log -msg_type "Info" -log_msg " restarting IIS"
try {
iisreset
Write-log -msg_type "Info" -log_msg "IIS Reset successful" 
}
catch {
Write-log -msg_type "Error" -log_msg " IIS Not Reset -Error = $_"
 $erroflag=1
} 
if ($errorflag -ne 0)
{
    Write-log -msg_type "Fail" -log_msg "Deploy Failed "
	Deploy_SendStatus -dep_status "FAIL" -dep_version_pkg "$version_pkg"
}
   else 
   {
      Write-log -msg_type "Success" -log_msg "Deploy Successful "
      Deploy_SendStatus -dep_status "SUCCESS" -dep_version_pkg "$version_pkg"
   }
}
			
