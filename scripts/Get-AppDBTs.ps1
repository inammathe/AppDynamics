<#
.SYNOPSIS
    Gets all business transaction details for a an application
.DESCRIPTION
    Gets all business transaction details for a an application
.EXAMPLE
    PS C:\> Get-AppDBTs -AppId 6

    Returns business transaction information for Application 6
.EXAMPLE
    PS C:\> Get-AppDBTs -AppName 'MyApp'

    Returns business transaction information for MyApp
#>
function Get-AppDBTs {
    [CmdletBinding()]
    param(
        # Mandatory application ID.
        [Parameter(Mandatory, Position = 0, ParameterSetName='AppId')]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory, Position = 0, ParameterSetName='AppName')]
        $AppName
    )
    Begin
    {
        Write-AppDLog "$(MyInvocation.MyCommand)"

        $c = New-AppDConnection

        if ($MyInvocation.MyCommand.ParameterSets -contains 'AppName') {
            $AppId = (Get-AppDApplication -AppName $AppName).id
            if (!$AppId) {
                $msg = "Failed to find application with application name: $AppName"
                Write-AppDLog -Message $msg -Level 'Error'
                Throw $msg
            }
        }
    }
    Process
    {
        $uri = "controller/api/accounts/$($c.accountId)/applications/$AppId/businesstransactions"
        Write-Verbose $uri
        Get-AppDResource -uri $uri
    }
}