<#
.Synopsis
    Gets AppD Policy information
.DESCRIPTION
    Queries the controller rest api for Policy information regarding an application.
.EXAMPLE
    PS C:\> Get-AppDPolicies -AppId 1

    Returns all Policies for application 1
#>
function Get-AppDPolicies
{
    [CmdletBinding()]
    Param
    (
        # Mandatory application ID.
        [Parameter(Mandatory=$true, ValueFromPipeline)]
        $AppId
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
        $connectionInfo = New-AppDConnection
    }
    Process
    {
        $AppId = Test-AppId -AppDid $AppId -ErrorAction Stop
        foreach ($id in $AppId) {
            Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/policies" -connectionInfo $connectionInfo
        }
    }
}