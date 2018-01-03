<#
.Synopsis
    Gets AppD Tier information
.DESCRIPTION
    Queries the controller rest api for tier information regarding an application.
.EXAMPLE
    PS C:\> Get-AppDTier -AppId 1

    Returns all tiers for application 1
.EXAMPLE
    PS C:\> Get-AppDTier -AppId 1 -TierId 32

    Returns tier 32 for application 1
#>
function Get-AppDTier
{
    [CmdletBinding()]
    Param
    (
        # Mandatory application ID.
        [Parameter(Mandatory=$true, ValueFromPipeline)]
        $AppId,

        # Optional Tier ID.
        [Parameter(Mandatory=$false)]
        $TierId
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
        $connectionInfo = New-AppDConnection
    }
    Process
    {
        foreach ($id in $AppId) {
            $result = @()
            if (!$TierId) {
                $result += Get-AppDResource -uri "controller/rest/applications/$id/tiers" -connectionInfo $connectionInfo
            }
            else {
                foreach ($tier in $TierId) {
                    $result += Get-AppDResource -uri "controller/rest/applications/$id/tiers/$tier" -connectionInfo $connectionInfo
                }
            }
            if($result)
            {
                $result = $result.tiers.tier
                foreach ($res in $result) {
                    [PSCustomObject]@{
                        id = $res.id
                        name = $res.name
                        type = $res.type
                        agentType = $res.agentType
                        numberOfNodes = $res.numberOfNodes
                    }
                }
            }
        }
    }
}