<#
.SYNOPSIS
    Gets all License details for a an application
.DESCRIPTION
    Gets all License details for a an application. Includes all usage data and properties
.EXAMPLE
    PS C:\> Get-AppDLicenseInfo

    Returns License information
#>
function Get-AppDLicenseInfo {
    [CmdletBinding()]
    param()
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
        $connectionInfo = New-AppDConnection
    }
    Process
    {
        $modules = Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/licensemodules" -connectionInfo $connectionInfo | Select-Object -ExpandProperty Modules
        foreach ($module in $modules) {
            $Name = $module.name
            $ModuleLinks = $module.links

            #Usages
            foreach ($link in $ModuleLinks | Where-Object {$_.Name -eq 'usages'} ) {
                $uri = ([uri]$link.href).AbsolutePath
                try {
                    $Usages = Get-AppDResource -uri $uri -connectionInfo $connectionInfo
                }
                catch [System.Net.WebException] {
                    $Usages = $null
                }
            }

            #Properties
            foreach ($link in $ModuleLinks | Where-Object {$_.Name -eq 'properties'} ) {
                $uri = ([uri]$link.href).AbsolutePath
                try {
                    $Properties = Get-AppDResource -uri $uri -connectionInfo $connectionInfo
                }
                catch [System.Net.WebException] {
                    $Properties = $null
                }
            }

            #expand and clean
            if ($Usages.Usages) {
                $Usages = $Usages | Select-Object -ExpandProperty Usages
                for ($i = 0; $i -lt $Usages.Count; $i++) {
                    $Usages[$i].CreatedOn = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddMilliseconds($Usages[$i].CreatedOn))
                }
            }

            if ($Properties.Properties) {
                $Properties = $Properties | Select-Object -ExpandProperty Properties
                for ($i = 0; $i -lt $Properties.Count; $i++) {
                    $milliseconds = ($Properties[$i] | Where-Object {$_.name -eq 'expiry-date'}).value
                    if ($Properties[$i].name -eq 'expiry-date') {
                        $Properties[$i].value  = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddMilliseconds($milliseconds))
                    }
                }
            }

            [PSCustomObject]@{
                Name = $Name
                Usages = $Usages
                Properties = $Properties
            }
        }
    }
}