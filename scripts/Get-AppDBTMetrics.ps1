
function Get-AppDBTMetrics {
    $chosenApp = Get-AppDApplications | Out-GridView -PassThru
    $chosenbusinessTrans = (Get-AppDBTs -appid ($chosenApp.Id)).bts | Out-GridView -PassThru
    if($chosenbusinessTrans)
    {
        $MetricPaths = Get-AppDBTMetricPath -appId ($chosenApp.Id) -btId $chosenbusinessTrans.id
    }
    else {
        $MetricPaths = Get-AppDBTMetricPath -appId ($chosenApp.Id)
    }
    $MetricData = Get-AppDMetricData -MetricPath $MetricPaths -AppName $chosenApp.name
    $MetricData | Export-Csv -NoTypeInformation ".\$($chosenApp.name)-$((Get-Date -Format 'dd-MM-yy')).csv"
    $MetricData | Out-GridView
}