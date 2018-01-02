<#
.Synopsis
   Sets the current AppDynamics connection info (URL and API Key).

   Highly recommended to call this function from $profile to avoid having to re-configure this on every session.
.DESCRIPTION
   Sets the current AppDynamics connection info (URL and API Key). Will default to a guest account

   Highly recommended to call this function from $profile to avoid having to re-configure this on every session.
.EXAMPLE
   Set-AppDynamicsConnectionInfo -URL "http://MyAppDynamics.AwesomeCompany.com"

   Set connection info with a specific Auth string for an AppDynamics instance
#>
function Set-AppDConnectionInfo
{
    [CmdletBinding()]
    Param
    (
        # AppDynamics URL
        [Parameter(Mandatory=$true)]
        [string]$URL = 'http://appdynamics.contoso.com:8090',

        # AppDynamics username
        [Parameter(Mandatory=$false)]
        [string]$Username = 'guest',

        # AppDynamics password
        [Parameter(Mandatory=$false)]
        [string]$Password = 'guest',

        # Use this switch to force a retreival of the Account Id (otherwise it will take whatever is in the $env:AppDAccountID variable)
        [switch]
        $Force
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)`tURL: $URL"
    }
    Process
    {
        $env:AppDURL = $URL
        $env:AppDAuth = Get-AppDAuth -UserName $Username -Password $Password
        $env:AppDAccountID = Get-AppDAccountId -Force $Force
    }
    End
    {
        Get-AppDConnectionInfo
    }
}