#GET /accounts/{acctId}/applications/{appId}/businesstransactions
function Get-AppDBTs {
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
        $uri = "controller/api/accounts/$($c.accountId)/applications/$AppId/businesstransactions"
        Write-Verbose $uri
        Get-AppDResource -uri $uri
    }
}
