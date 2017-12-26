[![Build status](https://ci.appveyor.com/api/projects/status/lcqp4n6ahjv4ysoq/branch/master?svg=true)](https://ci.appveyor.com/project/inammathe/appdynamics/branch/master)

# AppDynamics
PowerShell module of various helpful cmdlets which can be used to manage various aspects of AppDynamics.

## Installation
Simply import  `.\AppDynamics\AppDynamics.psd1`. AppDynamics.psm1 has a handful of utility functions and will load all the scripts in the `.\scripts` directory upon importing the module.

## Example Use
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
