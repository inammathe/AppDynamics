<#
.Synopsis
   Creates an endpoint to connect to Appdynamics
.DESCRIPTION
   Creates an endpoint to connect to Appdynamics
.EXAMPLE
   $c = New-AppDConnection ; $c.repository.environments.findall()

   Get all the environments on the Appdynamics  instance using New-Appdynamics Connection and the Appdynamics .client
.EXAMPLE
   $c = New-AppDConnection ; invoke-webrequest -header $c.header -uri http://Appdynamics.company.com/api/environments/all -method Get

   Use the [Header] Member of the Object returned by New-Appdynamics Connection as a header to call the REST API using Invoke-WebRequest
.LINK
   Github project: https://github.com/Dalmirog/Octoposh
   Wiki: https://github.com/Dalmirog/OctoPosh/wiki
   QA and Cmdlet request: https://gitter.im/Dalmirog/OctoPosh#initial
#>
function New-AppDConnection
{
    [CmdletBinding()]
    param()
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"

        If((([string]::IsNullOrEmpty($env:AppDURL)) -or ([string]::IsNullOrEmpty($env:AppDAuth))) -or ([string]::IsNullOrEmpty($env:AppDAccountID)))
        {
            throw "At least one of the following variables does not have a value set: `$env:AppDURL or `$env:AppDAuth or `$env:AppDAccountID.`n`nUse Set-AppDConnectionInfo to set these values"
        }
    }
    Process
    {
        $properties = [ordered]@{
            accountId = $env:AppDAccountID
            header = @{'Authorization' = $env:AppDAuth}
        }

        $output = New-Object psobject -Property $properties
    }
    End
    {
        return $output
    }
}