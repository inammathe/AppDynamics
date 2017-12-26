<#
.SYNOPSIS
    Gets all nodes associated with a application
.DESCRIPTION
    Gets all nodes associated with a application
.EXAMPLE
    PS C:\> Get-AppDNodes
#>
function Get-AppDNodes
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
        Get-AppDResource -uri "controller/api/accounts/$($c.accountId)/applications/$AppId/nodes"
    }
}