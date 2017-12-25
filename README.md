# AppDynamics
PowerShell module of various helpful cmdlets which can be used to manage various aspects of AppDynamics.

## Installation
Simply import  `.\AppDynamics\AppDynamics.psd1`. AppDynamics.psm1 has a handful of utility functions and will load all the scripts in the `.\scripts` directory upon importing the module.

## Example Use
```
Import-Module '.\AppDynamics.psd1'

# Set Authorization and controller url
$auth = Get-AppDAuth -UserName 'guest@customer1' -Password 'guest'
$baseUrl = 'http://appdynamics.contoso.com:8090'

# Get all Applications
Get-AppDApplications -auth $auth -baseUrl $baseUrl

# Get some Business transaction metric data
$appName = 'UBET'
$MetricPaths = Get-AppDBTMetricPath -AppName $appName  | Select-Object -First 5
Get-AppDMetricData -MetricPath $MetricPaths -AppName $appName | Out-GridView
```
