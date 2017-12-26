<#
.SYNOPSIS
    Gets business transaction metrics
.DESCRIPTION
    Gets business transaction metrics with optional exporting to CSV
.EXAMPLE
    PS C:\> Get-AppDBTMetrics
#>
function Get-AppDBTMetrics
{
    [CmdletBinding()]
    param
    (
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [switch]
        $Interactive
    )
    Begin
    {
        Write-AppDLog "$(MyInvocation.MyCommand)"
    }
    Process
    {
        $chosenApp = Get-AppDApplication | Out-GridView -PassThru
        $chosenbusinessTrans = (Get-AppDBTs -appid ($chosenApp.Id)).bts | Out-GridView -PassThru
        if ($chosenbusinessTrans) {
            $MetricPaths = Get-AppDBTMetricPath -appId ($chosenApp.Id) -btId $chosenbusinessTrans.id
        }
        else {
            $MetricPaths = Get-AppDBTMetricPath -appId ($chosenApp.Id)
        }
        $MetricData = Get-AppDMetricData -MetricPath $MetricPaths -AppName $chosenApp.name
        $MetricData | Export-Csv -NoTypeInformation ".\$($chosenApp.name)-$((Get-Date -Format 'dd-MM-yy')).csv"
        $MetricData | Out-GridView
    }
}