$version=$args[0]
$workspace=$args[1]
$pkg_location="c:\Package_Install\"
$ini_file="$pkg_location\Package_version.ini"
Write-Host "Version is $version Worspace is $workspace"
$Ver=$version+"-Stage-Beta"
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
		   default {
		      Write-Host " Error - not import INI file "
			  
	         }
	
	}

	
}
else 
{ 
  Write-Host "File not found - $ini_file"
  $errorflag=1
 
   cmd /c "exit 10"
        Throw "Error: Package info file not found " 
  }
  $ini
}

$ini_content=Import-ini -Path $ini_file 
$env_type=$ini_content["Packageid-1"]["env_type"]
$version_pkg=$ini_content["Packageid-1"]["version_pkg"]
$download_status_file="$pkg_location\download_status.$version_pkg.config.temp"
if (Test-Path -Path $download_status_file)
{ 
   Remove-Item $download_status_file -Recurse
}
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


Push-Location $pkg_location
try {
Remove-Item ".\Nuget_pkg\*" -Recurse 
Write-log -msg_type "Info" -log_msg "Removed old Nuget Packages"
}
catch [System.Management.Automation.ActionPreferenceStopException] {

Write-log -msg_type "Error" -log_msg "Cannot Remove Nuget Package, Maybe Nuget Package Absent"

}


Write-Host "Getting Nuget Packages "
Foreach ( $i in $ini_content.keys )
    { $pkg_id=$ini_content[$i]["pkg_id"]
	  $version_pkg=$ini_content[$i]["version_pkg"]
	  $environment=$ini_content[$i]["env_type"] 
	  $retry_cnt=0
	   while ($retry_cnt -le 2 )
	   {
	    try {
	  .\nuget install $pkg_id -Version $version_pkg -Prerelease -source http://nuget.intuit.com/nuget -Verbosity detailed -OutputDirectory .\Nuget_pkg\
	     $retry_cnt=5
		Write-log -msg_type "Info" -log_msg "Successfully Downloaded Pkg $pkg_id with Version $version_pkg"
		
	 }
	 catch [System.Net.WebException],[System.IO.IOException],[System.InvalidOperationException]
	 		{ 
			Write-log -msg_type "Error" -log_msg "Could not download Pkg $pkg_id with Version $version_pkg"
	          $retry_cnt += 1 
	 }
	 catch {
	     Write-log -msg_type "Error" -log_msg "Could not download Pkg $pkg_id with Version $version_pkg"
		  $retry_cnt += 1 
	 }
	 
	 }
	 
	}
	
	Start-Sleep -s 15 
Write-Host "Checking if Packages Downloaded"
Foreach ($i in $ini_content.keys )
{
  $pkg_id=$ini_content[$i]["pkg_id"]
	  $version_pkg=$ini_content[$i]["version_pkg"]
	  
	  if (Test-Path -Path "$pkg_location\Nuget_Pkg\$pkg_id.$version_pkg")
	      { Write-Host "Info:Package $pkg_id.$version_pkg Verified "
		    Write-log -msg_type "Info" -log_msg "Package $pkg_id.$version_pkg Verified"
			}
			else 
			{
			    Write-Host "Error:Package $pkg_id.$version_pkg not Verified "
		    Write-log -msg_type "Error" -log_msg "Package $pkg_id.$version_pkg not  Verified"
			$errorflag=1
			}
}

	if ( $errorflag -ne 0)
	     {
		   Write-log -msg_type "Unsuccess" -log_msg "Package Download Unsucessfull..Retry in a 1 min "
		   Remove-Item $ini_file -Recurse
		  
		 }
		 else
		 {
		    Write-log -msg_type "Success" -log_msg "Package Download Successful"
			New-Item -ItemType file "$download_status_file" -Force
			
		 }
		 
Pop-Location


		 

