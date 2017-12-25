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
.LINK
   Github project: ghttps://github.com/Dalmirog/Octoposh
#>
function Set-AppDConnectionInfo
{
    [CmdletBinding()]
    Param
    (
        # AppDynamics URL
        [Parameter(Mandatory=$false)]
        [string]$URL = 'http://appdynamics.contoso.com:8090',

        # AppDynamics username
        [Parameter(Mandatory=$false)]
        [string]$Username = 'guest',

        # AppDynamics password
        [Parameter(Mandatory=$false)]
        [string]$Password = 'guest'
    )
    Begin
    {

    }
    Process
    {
        # Create authorization string
        if ($Username -notmatch '.+?@customer1$') #ends with @customer1
        {
            $Username += '@customer1'
        }
        $auth = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username`:$password")))

        $env:AppDURL = $URL
        $env:AppDAuth = $auth
        $env:AppDAccountID = Get-AppDAccountId
    }
    End
    {
        Get-AppDConnectionInfo
    }
}