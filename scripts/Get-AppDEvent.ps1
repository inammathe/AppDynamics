<#
.SYNOPSIS
    Gets all AppDynamics events of a given type
.DESCRIPTION
    Gets all AppDynamics events of a given type.
.EXAMPLE
    PS C:\> Get-AppDEvent -AppId 6 -daysago 7 -eventtype 'APPLICATION_DEPLOYMENT' -severities 'INFO'

    This will return the last 7 days of application deployment events
#>
function Get-AppDEvent
{
    [CmdletBinding()]
    param(
        # Mandatory application ID.
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory=$false)]
        $AppName,

        # How many days back to search. Ranges not yet supported by this cmdlet
        $daysAgo = 32,

        # Type of the event. See https://docs.appdynamics.com/display/PRO42/Events+Reference for potential types
        $eventType = 'APPLICATION_DEPLOYMENT',

        # Severity of the event
        [ValidateSet('INFO','WARN','ERROR', ignorecase=$False)]
        $severities = 'INFO,WARN,ERROR'
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"

        $connectionInfo = New-AppDConnection
    }
    Process
    {
        $daysAgoInMins = [MATH]::Round(((Get-Date) - ((Get-Date).AddDays(-$daysAgo))).TotalMinutes)

        # Get AppId if it is missing
        if (!$AppId -and $AppName) {
            $AppId = (Get-AppDApplication -AppId $AppName).Id
        }
        elseif (-not $AppId -and -not $AppName)
        {
            $AppId = (Get-AppDApplication).Id
        }

        foreach ($id in $AppId) {
            Get-AppDResource -uri "controller/rest/applications/$id/events?event-types=$eventType&severities=$severities&time-range-type=BEFORE_NOW&duration-in-mins=$daysAgoInMins&output=JSON" -connectionInfo $connectionInfo
        }
    }
}