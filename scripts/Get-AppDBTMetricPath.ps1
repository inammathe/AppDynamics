function Get-AppDBTMetricPath
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        $BaseUrl = (Get-AppDBaseUrl -controller 'Production'),
        $appName = 'contoso',
        $appId,
        $btId
    )
    if (!$appid) {
        if (!$appName) {
            throw "Application AppId or Application Name required. Use Get-AppDApplications to get application names and Ids"
        }

        $appId = ((Get-AppDApplications).applications | Where-Object {$_.name -eq 'contoso'}).id

    }
    if ($btId) {
        $BTs = (Get-AppDBTs -appid $appId -baseUrl $baseUrl).bts | Where-Object {$_.id -in $btid}
    }
    else
    {
        $BTs = (Get-AppDBTs -appid $appId -baseUrl $baseUrl).bts
    }

    foreach ($bt in $BTs) {
        $MetricPath = [System.Web.HttpUtility]::UrlEncode("$($bt.applicationComponentName)|$($bt.internalName)")
        Write-Output $MetricPath
    }
}
