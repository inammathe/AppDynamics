<#
.SYNOPSIS
    Gets AppD authorization header string required for rest API calls to AppDynamics
.DESCRIPTION
    Gets AppD authorization header string required for rest API calls to AppDynamics. defaults to readonly guest account
.EXAMPLE
    PS C:\> Get-AppDAuth -UserName "someone@customer1" -Password "yourpassword"

    Returns an base 64bit string representing your authorization to be used in subsequent AppDynamics rest API calls
#>
function Get-AppDAuth
{
    [CmdletBinding()]
    param(
        # Username containing @accountname required for auth -e.g. someone@customer1
        [Parameter(Mandatory = $false)]
        [String]
        $UserName = 'guest@customer1',

        # Password required for auth
        [Parameter(Mandatory = $false)]
        [String]
        $Password = 'guest'
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"
    }
    Process
    {
        if ($Username -notmatch '.+?@[a-zA-Z0-9]+$') #ends with @someAccountName
        {
            $Username += '@customer1'
        }
        Write-Output ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName + ":" + $Password )))
    }
}