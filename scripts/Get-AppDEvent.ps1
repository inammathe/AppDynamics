function Get-AppDEvent
{
    [CmdletBinding()]
    param(
        $AppId = ((Get-AppDApplications).applications | Where-Object {$_.name -eq 'contoso'}).id,
        $daysAgo = 32,
        $eventType = 'APPLICATION_DEPLOYMENT',
        [ValidateSet('INFO','WARN','ERROR',"INFO,WARN,ERROR", ignorecase=$False)]
        $severities = 'INFO,WARN,ERROR'
    )
    Begin
    {
        $c = New-AppDConnection
    }
    Process
    {
        $daysAgoInMins = [MATH]::Round(((Get-Date) - ((Get-Date).AddDays(-$daysAgo))).TotalMinutes)

        $url = "controller/rest/applications/$AppId/events?event-types=$eventType&severities=$severities&time-range-type=BEFORE_NOW&duration-in-mins=$daysAgoInMins&output=JSON"
        write-verbose $url
        Get-AppDResource -uri $url -verbose
    }
}