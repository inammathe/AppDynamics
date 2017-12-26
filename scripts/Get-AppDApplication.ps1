
<#
.SYNOPSIS
    Gets all registered AppDynamics applications
.DESCRIPTION
    Gets all registered AppDynamics applications via the AppDynamics controller accounts api
.EXAMPLE
    PS C:\> Get-AppDApplication

    Returns all registered application detail
.EXAMPLE
    PS C:\> (1..3) | Get-AppDApplication

    Returns application details for Applications 1 2 and 3
.EXAMPLE
    PS C:\> ('Contoso','MyApp') | Get-AppDApplication

    Returns application details for Contoso and MyApp Applications
#>
function Get-AppDApplication
{
    [CmdletBinding()]
    param
    (
        # Optional application ID. Supply this to get details regarding specific application/s.
        [Parameter(Mandatory = $false, ValueFromPipeline, Position = 0, ParameterSetName = 'AppId')]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory = $false, ValueFromPipeline, Position = 0, ParameterSetName = 'AppName')]
        $AppName
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
        $connectionInfo = New-AppDConnection
    }
    Process
    {
        switch ($MyInvocation.MyCommand.ParameterSets) {
            'AppId' {
                foreach ($id in $AppId) {
                    Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications/$id" -connectionInfo $connectionInfo
                }
            }
            'AppName' {
                foreach ($name in $AppName) {
                    Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications/$name" -connectionInfo $connectionInfo
                }
            }
            Default {
                Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications" -connectionInfo $connectionInfo
            }
        }
    }
}