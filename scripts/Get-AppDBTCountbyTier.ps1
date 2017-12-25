#GET /accounts/{acctId}/applications/{appId}/businesstransactions
function Get-AppDBTCountbyTier {
    [CmdletBinding()]
    Param(
        $AppId = ((Get-AppDApplications).applications | Where-Object {$_.name -eq 'contoso'}).id
    )
    Begin
    {
        $c = New-AppDConnection
    }
    Process
    {

        $BTs = Get-AppDBTs -AppId $AppId

        $total = 0
        $BTCounts = @()
        foreach($tier in $BTs.bts.applicationComponentName | sort-object -Unique){
            $total += ($BTs.bts.applicationComponentName | Where-Object {$_ -eq $tier}).Count
            $BTCounts += [pscustomobject]@{
                Tier = $tier
                BTCount = ($BTs.bts.applicationComponentName | Where-Object {$_ -eq $tier}).Count
            }
        }
        $BTCounts | Sort-Object BTCount -Descending
        Write-Host "`nTotal: $total" -ForegroundColor Green
    }
}