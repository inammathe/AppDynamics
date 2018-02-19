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
        $AppId,

        # Optional array of policy IDs.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $PolicyId
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
            if ($PolicyId) {
                foreach ($polId in $PolicyId) {
                    Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/policies/$polId" -connectionInfo $connectionInfo
                }
            }
            else
            {
                Get-AppDResource -uri "controller/api/accounts/$($connectionInfo.accountId)/applications/$id/policies" -connectionInfo $connectionInfo
            }
        }
    }
}