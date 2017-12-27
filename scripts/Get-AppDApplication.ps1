
<#
.SYNOPSIS
    Gets all registered AppDynamics applications
.DESCRIPTION
    Gets all registered AppDynamics applications via the AppDynamics controller accounts api.
    Supplying the AppId will always be far more efficient then just the AppName.
    If neither the AppId or AppName are supplied then every application and its details will be returned
.EXAMPLE
    PS C:\> Get-AppDApplication

    Returns all registered application detail
.EXAMPLE
    PS C:\> (1..3) | Get-AppDApplication

    Returns application details for Applications 1 2 and 3
.EXAMPLE
    PS C:\> ('Contoso','MyApp') | Get-AppDApplication

    Returns application details for Contoso and MyApp Applications
.NOTES
    I decided to not use the generic /applications/ endpoint (no id) int he final returen value due to missing properties in the response e.g. links.
#>
function Get-AppDApplication
{
    [CmdletBinding()]
    param
    (
        # Mandatory application ID.
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        $AppId,

        # Use the name of the application if you do not know the AppId
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
        if ($AppId) {
            foreach ($id in $AppId) {
                Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications/$id" -connectionInfo $connectionInfo
            }
        } elseif ($AppName) {
            foreach ($name in $AppName) {
                $AppId = Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications/" -connectionInfo $connectionInfo |
                    Select-Object -expandProperty applications | Where-Object {$_.name -eq $name} |
                        Select-Object -expandProperty id
                if ($AppId) {
                    Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications/$AppId" -connectionInfo $connectionInfo
                } else {
                    $msg = "Failed to find application with application name: $name"
                    Write-AppDLog -Message $msg -Level 'Error'
                    Throw $msg
                }
            }
        }
        if (-not $AppName -and -not $AppId) {
            $AppId = (Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications" -connectionInfo $connectionInfo |
                Select-Object -expandProperty applications).Id
            foreach ($id in $AppId) {
                Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountID)/applications/$id" -connectionInfo $connectionInfo
            }
        }
    }
}