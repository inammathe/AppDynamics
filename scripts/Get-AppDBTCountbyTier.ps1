<#
.SYNOPSIS
    Gets the count of business transactions per registered tier of an Application
.DESCRIPTION
    Gets the count of business transactions per registered tier of an Application
.EXAMPLE
#>
function Get-AppDBTCountbyTier {
    [CmdletBinding()]
    param(
        # Application ID.
        [Parameter(Mandatory=$false,ValueFromPipeline)]
        $AppId,

        # Use the name of the application if you do not know the AppId. Less efficient than using the ID
        [Parameter(Mandatory=$false)]
        $AppName
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
    }
    Process
    {
        if ($AppId) {
            $BTs = Get-AppDBTs -AppId $AppId
        }
        elseif ($AppName)
        {
            $BTs = Get-AppDBTs -AppName $AppName
        }
        elseif (-not $AppId -and -not $AppName)
        {
            $BTs = Get-AppDBTs
        }

        $total = 0
        $BTCounts = @()
        foreach($tier in $BTs.applicationComponentName | sort-object -Unique){
            $total += ($BTs.applicationComponentName | Where-Object {$_ -eq $tier}).Count
            $BTCounts += [pscustomobject]@{
                Tier = $tier
                BTCount = ($BTs.applicationComponentName | Where-Object {$_ -eq $tier}).Count
            }
        }
        $BTCounts | Sort-Object BTCount -Descending
        Write-Host "`nTotal: $total" -ForegroundColor Green
    }
}