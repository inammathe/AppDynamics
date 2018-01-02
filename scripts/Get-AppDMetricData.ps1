<#
.SYNOPSIS
    Gets Metric data
.DESCRIPTION
    Queries the rest API and returns an object containing the metric information
.PARAMETER MetricPath
    Rest path to the desired metric
    You can get this by right clicking a metric in the metric browser and selecting 'Copy REST Url'
    e.g.
    http://appdynamics.contoso.com:8090/controller/rest/applications/Asgard/metric-data?metric-path=Business%20Transaction%20Performance%7CBusiness%20Transactions%7CAsgard%7CAccountsWorkflow.LogonAccountDob%7CCalls%20per%20Minute&time-range-type=BEFORE_NOW&duration-in-mins=15
.PARAMETER Auth
    Authorization header required by AppDynamics rest API.
    You can get this either by using this module's Get-AppDAuth cmdlet OR by making it yourself
    e.g.
    $auth = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('yourusername@customer1' + ":" + 'yourpassword' ))
.EXAMPLE
    $auth = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('yourusername@customer1' + ":" + 'yourpassword' ))
    $metricPaths = @(
        http://appdynamics.contoso.com:8090/controller/rest/applications/Asgard/metric-data?metric-path=Business%20Transaction%20Performance%7CBusiness%20Transactions%7CAsgard%7CAccountsWorkflow.LogonAccountDob%7CCalls%20per%20Minute&time-range-type=BEFORE_NOW&duration-in-mins=15
    )
    $metricPaths | Get-MetricData -Auth $auth

    This will get the overall business transactions per minute metric data for the Asgard application metric 'AccountsWorkflow.LogonAccountDob'
.INPUTS
    String[]]
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
#>
function Get-AppDMetricData
{
    [CmdletBinding()]
    Param(
        # Mandatory application ID.
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory=$false)]
        $AppName,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]]$MetricPath,

        [Parameter(Mandatory=$false)]
        [String]
        $MinsAgo = '240'
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"

        $connectionInfo = New-AppDConnection
    }
    Process
    {
        # Get AppId if it is missing
        if (!$AppId -and $AppName) {
            $AppId = (Get-AppDApplication -AppName $AppName).Id
        }
        elseif (-not $AppId -and -not $AppName)
        {
            $AppId = (Get-AppDApplication).Id
        }
        if (!$AppId) {
            $msg = "Failed to find an Application ID on the controller"
            Write-AppDLog -Message $msg -Level 'Error'
            Throw $msg
        }

        <# Chosen metric types
            |Average Response Time (ms)
            |Calls per Minute
            |Errors per Minute
            |Number of Slow Calls
            |Stall Count
        #>
        $metricTypes = @("%7CAverage%20Response%20Time%20%28ms%29","%7CCalls%20per%20Minute","%7CErrors%20per%20Minute","%7CNumber%20of%20Slow%20Calls","%7CStall%20Count")

        $URLS =@()
        foreach ($path in $MetricPath) {
            foreach ($type in $metricTypes) {
                $URLS +=  "controller/rest/applications/6/metric-data?metric-path=Business%20Transaction%20Performance%7CBusiness%20Transactions%7C" + $path + $type + "&time-range-type=BEFORE_NOW&duration-in-mins=$MinsAgo"
            }
        }
        $URLS = $URLS.Replace(' ','%20')
        $URLS = $URLS.Replace('|','%7C')

        $URLS | ForEach-Object { Write-Verbose $_ }

        foreach ($url in $URLS) {
            $response = Get-AppDResource -uri $url -connectionInfo $connectionInfo

            [PSCustomObject]@{
                metricId = $response.'metric-datas'.'metric-data'.metricId
                metricPath = $response.'metric-datas'.'metric-data'.metricPath
                metricName = $response.'metric-datas'.'metric-data'.metricName
                frequency = $response.'metric-datas'.'metric-data'.frequency
                startTime = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddMilliseconds(($response.'metric-datas'.'metric-data'.metricValues.'metric-value'.startTimeInMillis)))
                value  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.value
                min  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.min
                max  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.max
                current  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.current
                sum  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.sum
                count  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.count
                standardDeviation  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.standardDeviation
                occurrences  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.occurrences
                useRange  = $response.'metric-datas'.'metric-data'.metricValues.'metric-value'.useRange
            }
        }
    }
}