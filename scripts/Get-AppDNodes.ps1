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
        $AppId = Test-AppId -AppDId $AppId -AppDName $AppName

        foreach ($id in $AppId) {
            Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/nodes" -connectionInfo $connectionInfo
        }
    }
}