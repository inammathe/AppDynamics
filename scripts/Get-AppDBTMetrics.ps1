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
        # Use a gui
        [Parameter(Mandatory=$true, Position = 0, ParameterSetName='Interactive')]
        [switch]
        $Interactive,

        # Don't use a gui
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName='Auto')]
        $AppId,

        [Parameter(Mandatory = $false)]
        $BTId,

        # Export CSV
        [Parameter(Mandatory = $false)]
        [switch]
        $ExportCSV,

        # Destination for the CSV export
        [Parameter(Mandatory = $false)]
        [string]
        $LiteralPath
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
    }
    Process
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Interactive' {
                $chosenApp = Get-AppDApplication | Out-GridView -PassThru
                $chosenbusinessTrans = (Get-AppDBTs -Appid ($chosenApp.Id)) | Out-GridView -PassThru
                if ($chosenbusinessTrans) {
                    $MetricPaths = Get-AppDBTMetricPath -AppID ($chosenApp.Id) -BtId $chosenbusinessTrans.Id
                } else {
                    $MetricPaths = Get-AppDBTMetricPath -AppID ($chosenApp.Id)
                }
                $MetricData = Get-AppDMetricData -MetricPath $MetricPaths -AppId $chosenApp.Id
                $MetricData | Out-GridView
              }
            'Auto' {
                $chosenApp = Get-AppDApplication -AppId $AppId
                if($BTId) {
                    $MetricPaths = Get-AppDBTMetricPath -AppId $AppId -BtId $BTId
                } else {
                    $MetricPaths = Get-AppDBTMetricPath -AppID $AppId
                }
                $MetricData = Get-AppDMetricData -MetricPath $MetricPaths -AppId $AppId
                Write-Output $MetricData
            }
        }

        if ($ExportCSV) {
            if ($LiteralPath) {
                $MetricData | Export-Csv -NoTypeInformation $LiteralPath
            }
            else {
                $MetricData | Export-Csv -NoTypeInformation ".\$($chosenApp.name)-$((Get-Date -Format 'dd-MM-yy')).csv"
            }
        }
    }
}