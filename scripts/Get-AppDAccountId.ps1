<#
.SYNOPSIS
    Gets the AccountId in the config
.DESCRIPTION
    Sets the AccountId in the config so other cmdlets can access the AccountId without having
    to query the API first.
    Will default to the Production controller if the controller is not specified.
.EXAMPLE
    PS C:\> Get-AppDAccountId

    Queries the controller API for the accountId at /controller/api/accounts/myaccount
#>
function Get-AppDAccountId
{
    [CmdletBinding()]
    param()
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
    }
    Process
    {
        if (([string]::IsNullOrEmpty($env:AppDAccountID))) {
            If (([string]::IsNullOrEmpty($env:AppDURL)) -or ([string]::IsNullOrEmpty($env:AppDAuth))) {
                throw "At least one of the following variables does not have a value set: `$env:AppDURL or `$env:AppDAuth. Use Set-AppDConnectionInfo to set these values"
            }
            else {
                $env:AppDAccountID = (Invoke-RestMethod -uri "$env:AppDURL/controller/api/accounts/myaccount" -Headers @{'Authorization' = $env:AppDAuth}).id
            }
        }
        Write-Output $env:AppDAccountID
    }
}