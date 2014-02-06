$dep_version=$args[0]
$dep_status=$args[1]
$dep_host=$args[2]

if ($dep_status -eq "SUCCESS")
     { Write-Host "Sucess: Deploy Job Successful  Version=$dep_version on Node=$dep_host"
	 }
	 else 
	 {   Write-Host "Fail: Deploy Job Unsuccessful  Version=$dep_version on Node=$dep_host"
	   cmd /c "exit 10"
	   Throw "The command exited with error code: $lastexitcode" 
        
	 }