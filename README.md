[![Build status](https://ci.appveyor.com/api/projects/status/q8xh0pndvsba0kpd?svg=true)](https://ci.appveyor.com/project/inammathe/appdynamics/branch/master)

# AppDynamics
This is a PowerShell module that exports a bunch of handy functions which can be used to manage various aspects of AppDynamics.
At the moment these functions are mostly just wrappers for the Appdynamics rest API but could easily be expanded to include agent or controller server management.
PRs or feature requests are most welcome :)

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

https://www.powershellgallery.com/packages/appdynamics/


## Manually:
1. Clone or download this repo https://github.com/inammathe/AppDynamics
2. `Import-Module .\AppDynamics\AppDynamics.psd1`.

AppDynamics.psm1 has a handful of utility functions and will load all the scripts in the `.\scripts` directory upon importing the module.

Example Use
======
```
Import-Module '.\AppDynamics.psd1'

# Set Connection information - Highly recommend you add this to your profile to save you having to do it every time.
Set-AppDynamicsConnectionInfo -URL 'http://MyAppDynamics.AwesomeCompany.com'

# Get all Applications
Get-AppDApplication

# Get some Business transaction metric data
$appName = 'TestApp'
$MetricPaths = Get-AppDBTMetricPath -AppName $appName  | Select-Object -First 5
Get-AppDMetricData -MetricPath $MetricPaths -AppName $appName | Out-GridView
```

CI/CD Pipeline
======
Adapted from http://ramblingcookiemonster.github.io/PSDeploy-Inception/#appveyor-and-powershell-gallery <- love this guy
## Scaffolding
* AppVeyor.yml. Instructions for AppVeyor. We’ll still use this, but we’ll try to move as much of the build as possible into PowerShell tooling that will work in other build systems.
* Start-Build.ps1. A build script that sets up our dependencies and kicks off psake. Portable across build systems. We install and use a few dependencies:
    * BuildHelpers. A module to help with portability and some common build needs
    * Psake. A build automation tool. Lets us define a series of tasks for our build
    * Pester. A testing framework for PowerShell
    * PSDeploy. A module to simplify PowerShell based deployments - Modules, in this case
* Psake.ps1. Tasks to run - testing, build (e.g. bump version number), and deployment to the PowerShell gallery
* deploy.psdeploy.ps1. Instructions that tell PSDeploy how to deploy our module

## Process
1. GitHub sends AppVeyor a notification of your commit
2. AppVeyor parses your appveyor.yml and starts a build on a fresh VM
3. build.ps1 installs dependencies, sets up environment variables with BuildHelpers, and kicks off psake.ps1
4. psake.ps1 does the real work. It runs your Pester tests, and if they pass, runs PSDeploy against your psdeploy.ps1
