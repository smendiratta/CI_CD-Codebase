$Configuration=$args[0]
$Test_Path=$args[1]
$workspace=$args[2]
$errorflag=0
Remove-Item "$workspace\*.NunitResult.xml"
$Location = "$workspace\$Test_Path\bin\$Configuration"
echo $Location 
Push-Location $Location
foreach( $file in Get-ChildItem $Location -Filter "*Test.dll"   )
{  $filename="$file".split('\.')[-2]
   echo $filename
    D:\Nunit_2.6.3\bin\nunit-console.exe $file /xml=$workspace\$filename.NunitResult.xml
    if($LASTEXITCODE -ne 0)
	{ $errorflag=1
	}
	
}
if ($errorflag -eq 1)
   { cmd /c "exit 10"
        Throw "The command exited with error code: -100" 
		}
		$errorflag=0
Pop-Location