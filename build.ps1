Install-Module PSDepend -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null

Invoke-PSDepend -Force -verbose

# For PS2, after installing with PS5.
#Move-Item C:\temp\pester\*\* -Destination C:\temp\pester -force