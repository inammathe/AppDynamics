<#
.SYNOPSIS
    Gets AppD authorization header string required for rest API calls to AppDynamics
.DESCRIPTION
    Gets AppD authorization header string required for rest API calls to AppDynamics. defaults to readonly guest account
.EXAMPLE
    Get-AppDAuth -UserName "someone@customer1" -Password "yourpassword"
#>
function Get-AppDAuth
{
    [CmdletBinding()]
    param(
        # Username containing @accountname required for auth -e.g. someone@customer1
        [Parameter(Mandatory=$false)]
        [String]
        $UserName = 'guest@customer1',

        # Password required for auth
        [Parameter(Mandatory=$false)]
        [String]
        $Password = 'guest'
    )
    Write-Output ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+":"+$Password )))
}