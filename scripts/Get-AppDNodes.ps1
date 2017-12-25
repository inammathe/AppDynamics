#GET /accounts/{acctId}/applications
function Get-AppDNodes {
    [CmdletBinding()]
    Param(
        $BaseUrl = (Get-AppDBaseUrl -controller 'Production'),
        $Auth = (Get-AppDAuth),
        $AppId = ((Get-AppDApplications).applications | Where-Object {$_.name -eq 'contoso'}).id
    )
    $accountID = Get-AppDAccountID -BaseUrl $BaseUrl -auth $auth
    if (!$appid) {
        $apps = Get-AppDApplications -BaseUrl $BaseUrl -auth $auth
        foreach ($app in $apps) {
            Write-Output (Invoke-RestMethod "$BaseUrl/controller/api/accounts/$accountID/applications/$($app.Id)/nodes" -Headers @{'Authorization' = $auth})
        }
    }
    else
    {
        Write-Output (Invoke-RestMethod "$BaseUrl/controller/api/accounts/$accountID/applications/$appid/nodes" -Headers @{'Authorization' = $auth})
    }
}