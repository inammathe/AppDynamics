function Get-AppDConfig
{
    [CmdletBinding()]
    param($moduleLocation = (Get-Item (Split-Path -parent $PSCommandPath)).parent.FullName)

    $configFile = "$moduleLocation\config\AppDynamics.JSON"

    if (Test-Path $configFile) {
       $config = Get-Content -Raw $configFile | ConvertFrom-Json
    }
    Write-Output $config
}