[![Build status](https://ci.appveyor.com/api/projects/status/q8xh0pndvsba0kpd?svg=true)](https://ci.appveyor.com/project/inammathe/appdynamics/branch/master)

# AppDynamics
PowerShell module of various helpful cmdlets which can be used to manage various aspects of AppDynamics.

Installation
======

## Using PowerShell Gallery:
If you have [WMF 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) or [PowerShellGet ](https://docs.microsoft.com/en-us/powershell/gallery/readme) installed:

```
#Inspect
PS> Save-Module -Name appdynamics -Path <path>
```
```
#Install
PS> Install-Module -Name appdynamics
```


## Manually:
1. Clone or download this repo https://github.com/inammathe/AppDynamics
2. `Import-Module .\AppDynamics\AppDynamics.psd1`.

AppDynamics.psm1 has a handful of utility functions and will load all the scripts in the `.\scripts` directory upon importing the module.

Example Use
======
```
Import-Module '.\AppDynamics.psd1'

# Set Connection information
Set-AppDynamicsConnectionInfo -URL "http://MyAppDynamics.AwesomeCompany.com"

# Get all Applications
Get-AppDApplication

# Get some Business transaction metric data
$appName = 'TestApp'
$MetricPaths = Get-AppDBTMetricPath -AppName $appName  | Select-Object -First 5
Get-AppDMetricData -MetricPath $MetricPaths -AppName $appName | Out-GridView
```
