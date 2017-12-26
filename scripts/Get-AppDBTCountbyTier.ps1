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
        # Mandatory application ID.
        [Parameter(Mandatory, Position = 0, Parametersetname='AppId')]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory, Position = 0, ParameterSetName='AppName')]
        $AppName
    )
    Begin
    {
        Write-AppDLog "$(MyInvocation.MyCommand)"

        if ($MyInvocation.MyCommand.ParameterSets -contains 'AppName')
        {
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