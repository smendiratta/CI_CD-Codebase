class quest {
if $osfamily == "windows" { 
 $windows_drive = "C:"   

file {"Package_install":
        path => "${windows_drive}\\Package_Install",
        ensure => directory,
        group => 'Administrator',
       }
file {"Nuget_Pkg":
       path => "${windows_drive}\\Package_Install\\Nuget_pkg",
       ensure => directory,
       group => 'Administrator',
     }
  
file { "Package_Version": 
         path => "${windows_drive}\\Package_Install\\Package_version.ini", 
         source => "puppet:///modules/quest/Package_version.ini",
         group  => 'Administrator', 
         }
file {"Nuget_exe":
       path => "${windows_drive}\\Package_Install\\nuget.exe",
       ensure => present, 
       source => "puppet:///modules/quest/nuget.exe",
       group => 'Administrator',
       mode =>  '0777',
}

file { "Download_pkg":
      path =>"${windows_drive}\\Package_Install\\DownloadNugetPkg_stg.ps1",
      ensure =>present,
      source => "puppet:///modules/quest/DownloadNugetPkg_stg.ps1",
      mode => '0777',
}
file { "PostDownload_pkg":
         path =>"${windows_drive}\\Package_Install\\Post_DownloadNugetPkg_stg.ps1",
      ensure =>present,
      source => "puppet:///modules/quest/Post_DownloadNugetPkg_stg.ps1",
      mode => '0777',
}

exec {"Download_pkg_script":
       command =>  "${windows_drive}\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy unrestricted -file ${windows_drive}\\Package_Install\\DownloadNugetPkg_stg.ps1",
        subscribe => File["Package_Version"], 
        notify => Exec["Post_Download_pkg_script"],
 refreshonly => true,
logoutput => true,
}

exec {"Post_Download_pkg_script":
       command =>  "${windows_drive}\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy unrestricted -file ${windows_drive}\\Package_Install\\Post_DownloadNugetPkg_stg.ps1",
logoutput => true,
 refreshonly => true,			
}

}

 }
