#GET /accounts/{acctId}/applications
function Get-AppDApplications {
    [CmdletBinding()]
    Param($c)
    Begin
    {
        $c = New-AppDConnection
    }
    Process
    {
        Get-AppDResource -uri "controller/api/accounts/$($c.accountID)/applications"
    }
}