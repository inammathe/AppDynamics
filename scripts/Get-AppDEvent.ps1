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
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        [string]
        $AppName,

        # Type of the event. See https://docs.appdynamics.com/display/PRO42/Events+Reference for potential types
        [Parameter(Mandatory=$true)]
        [ValidateSet(
            'ACTIVITY_TRACE','ADJUDICATION_CANCELLED','AGENT_ADD_BLACKLIST_REG_LIMIT_REACHED','AGENT_ASYNC_ADD_REG_LIMIT_REACHED','AGENT_CONFIGURATION_ERROR',
            'AGENT_DIAGNOSTICS','AGENT_ERROR_ADD_REG_LIMIT_REACHED','AGENT_EVENT','AGENT_METRIC_BLACKLIST_REG_LIMIT_REACHED','AGENT_METRIC_REG_LIMIT_REACHED',
            'AGENT_STATUS','ALREADY_ADJUDICATED','APPLICATION_CONFIG_CHANGE','APPLICATION_DEPLOYMENT','APPLICATION_ERROR',
            'APP_SERVER_RESTART','AZURE_AUTO_SCALING','BACKEND_DISCOVERED','BT_DISCOVERED','CONTROLLER_AGENT_VERSION_INCOMPATIBILITY',
            'CONTROLLER_ASYNC_ADD_REG_LIMIT_REACHED','CONTROLLER_ERROR_ADD_REG_LIMIT_REACHED','CONTROLLER_EVENT_UPLOAD_LIMIT_REACHED','CONTROLLER_METRIC_REG_LIMIT_REACHED','CONTROLLER_RSD_UPLOAD_LIMIT_REACHED',
            'CONTROLLER_STACKTRACE_ADD_REG_LIMIT_REACHED','CUSTOM','CUSTOM_ACTION_END','CUSTOM_ACTION_FAILED','CUSTOM_ACTION_STARTED',
            'DEADLOCK','DIAGNOSTIC_SESSION','DISK_SPACE','EMAIL_SENT','EUM_CLOUD_BROWSER_EVENT',
            'INFO_INSTRUMENTATION_VISIBILITY','INTERNAL_UI_EVENT','LICENSE','MACHINE_DISCOVERED','MEMORY',
            'MEMORY_LEAK_DIAGNOSTICS','MOBILE_CRASH_IOS_EVENT','MOBILE_CRASH_ANDROID_EVENT','NODE_DISCOVERED','NORMAL',
            'OBJECT_CONTENT_SUMMARY','POLICY_CANCELED_CRITICAL','POLICY_CANCELED_WARNING','POLICY_CLOSE_CRITICAL','POLICY_CLOSE_WARNING',
            'POLICY_CONTINUES_CRITICAL','POLICY_CONTINUES_WARNING','POLICY_DOWNGRADED','POLICY_OPEN_CRITICAL','POLICY_OPEN_WARNING',
            'POLICY_UPGRADED','RESOURCE_POOL_LIMIT','RUNBOOK_DIAGNOSTIC SESSION_END','RUNBOOK_DIAGNOSTIC SESSION_FAILED',
            'RUNBOOK_DIAGNOSTIC SESSION_STARTED','RUN_LOCAL_SCRIPT_ACTION_END','RUN_LOCAL_SCRIPT_ACTION_FAILED','RUN_LOCAL_SCRIPT_ACTION_STARTED',
            'SERVICE_ENDPOINT_DISCOVERED','SLOW','SMS_SENT','STALL','SYSTEM_LOG',
            'THREAD_DUMP_ACTION_END','THREAD_DUMP_ACTION_FAILED','THREAD_DUMP_ACTION_STARTED','TIER_DISCOVERED','VERY_SLOW',
            'WORKFLOW_ACTION_END','WORKFLOW_ACTION_FAILED','WORKFLOW_ACTION_STARTED',
        ignorecase=$False)]
        [string[]]
        $EventType,


        # Severity of the event
        [ValidateSet(
            'INFO',
            'WARN',
            'ERROR',
        ignorecase=$False)]
        [string[]]
        $Severities = 'INFO,WARN,ERROR',

        # Type of time range to use
        [ValidateSet(
            'BEFORE_NOW',
            'BEFORE_TIME',
            'AFTER_TIME',
            'BETWEEN_TIMES',
        ignorecase=$False)]
        [string]
        $TimeRangeType,

        # Specify the duration (in minutes) to return the metric data. Only applicable if TimeRangeType is BEFORE_NOW, BEFORE_TIME or AFTER_TIME
        [int]
        $DurationInMins,

        # Specify the start time from which the metric data is returned
        [DateTime]
        $StartTime,

        # Specify the end time from which the metric data is returned
        [DateTime]
        $EndTime
    )
    Begin
    {
        Write-AppDLog "$($MyInvocation.MyCommand)"

        $connectionInfo = New-AppDConnection
        function Test-DurationInMins($duration) {
            if(!$duration)
            {
                Write-AppDLog "DurationInMins must be supplied with this event type" -Level 'Error' -ErrorAction Stop
            }
        }

        function Get-TimeInMS($time, $type) {
            if(!$time)
            {
                Write-AppDLog "$type must be supplied with this event type" -Level 'Error' -ErrorAction Stop
            }

            Write-Output (ConvertTo-EpochTime -datetime (Get-Date $time))
        }

        # Validation
        switch ($TimeRangeType) {
            'BEFORE_NOW' {
                Test-DurationInMins -duration $DurationInMins
                $TimeRangeString = "duration-in-mins=$DurationInMins"
            }
            'BEFORE_TIME' {
                $endTimeInMS = Get-TimeInMS -time $EndTime -type 'end-time'
                Test-DurationInMins -duration $DurationInMins
                $TimeRangeString = "end-time=$endTimeInMS&duration-in-mins=$DurationInMins"
            }
            'AFTER_TIME' {
                $startTimeInMS = Get-TimeInMS -time $StartTime -type 'start-time'
                Test-DurationInMins -duration $DurationInMins
                $TimeRangeString = "start-time=$startTimeInMS&duration-in-mins=$DurationInMins"
            }
            'BETWEEN_TIMES' {
                $startTimeInMS = Get-TimeInMS -time $StartTime -type 'start-time'
                $endTimeInMS = Get-TimeInMS -time $EndTime -type 'end-time'

                if ($startTimeInMS -ge $endTimeInMS) {
                    Write-AppDLog "StartTime must be less than EndTime" -Level 'Error' -ErrorAction Stop
                }

                $TimeRangeString = "start-time=$startTimeInMS&end-time=$endTimeInMS"
            }
        }
    }
    Process
    {
        $AppId = Test-AppId -AppDId $AppId -AppDName $AppName

        foreach ($id in $AppId) {
            $response = Get-AppDResource -uri "controller/rest/applications/$id/events?event-types=$eventType&severities=$severities&time-range-type=$TimeRangeType&$TimeRangeString&output=JSON" -connectionInfo $connectionInfo
            foreach ($res in $response) {
                $res.eventTime = ConvertFrom-EpochTime -epochTime $res.eventTime -ToLocal
            }
            Write-Output $response
        }
    }
}