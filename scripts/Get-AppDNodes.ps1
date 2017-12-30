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
        # Get AppId if it is missing
        if (!$AppId -and $AppName) {
            $AppId = (Get-AppDApplication -AppId $AppName).Id
            if (!$AppId) {
                $msg = "Failed to find application with application name: $AppName"
                Write-AppDLog -Message $msg -Level 'Error'
                Throw $msg
            }
        }
        elseif (-not $AppId -and -not $AppName)
        {
            $AppId = (Get-AppDApplication).Id

        }
        foreach ($id in $AppId) {
            Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/nodes" -connectionInfo $connectionInfo
        }
    }
}