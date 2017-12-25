#GET /accounts/{acctId}/applications
function Get-AppDApplicationDetail {
    [CmdletBinding()]
    Param(
        $BaseUrl = (Get-AppDBaseUrl -controller 'Production'),
        $Auth = (Get-AppDAuth),
        $AppId = ((Get-AppDApplications).applications | Where-Object {$_.name -eq 'contoso'}).id,
        $AccountID = (Get-AppDAccountID)
    )
   Invoke-RestMethod "$BaseUrl/controller/api/accounts/$accountID/applications/$AppId" -Headers @{'Authorization' = $auth}
}
