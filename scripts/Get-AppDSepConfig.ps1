<#
.SYNOPSIS
    Gets all Service Endpoint configuration
.DESCRIPTION
    Gets all Service Endpoint configuration
.EXAMPLE
    PS C:\> Get-AppDSepConfig -AppId 6

    Returns service endpoint configuration information for Application 6
.EXAMPLE
    PS C:\> Get-AppDSepConfig -AppName 'MyApp'

    Returns service endpoint configuration information for MyApp
#>
function Get-AppDSepConfig {
    [CmdletBinding()]
    param(
        # Application ID.
        [Parameter(Mandatory=$false,ValueFromPipeline)]
        $AppId,

        # Tier ID
        [Parameter(Mandatory=$false)]
        $TierId,

        # Use the name of the application if you do not know the AppId. Less efficient than using the ID
        [Parameter(Mandatory=$false)]
        $AppName
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
        $connectionInfo = New-AppDConnection
    }
    Process
    {
        $AppId = Test-AppId -AppDId $AppId -AppDName $AppName

        foreach ($id in $AppId) {
            if ($TierId) {
                (Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/sep/tier/$tier" -connectionInfo $connectionInfo)
            }
            else
            {
                (Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/sep" -connectionInfo $connectionInfo)
            }
        }
    }
}