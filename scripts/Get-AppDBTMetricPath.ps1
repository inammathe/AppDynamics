<#
.SYNOPSIS
    Gets paths to business transaction metrics
.DESCRIPTION
    Gets paths to business transaction metrics
.EXAMPLE
    PS C:\> Get-AppDBTMetricPath -AppId 6

    Returns the metric paths to all business transactions of application 6
#>
function Get-AppDBTMetricPath
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # Mandatory application ID
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'AppId')]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'AppName')]
        $AppName,

        # Optional Id of a business transaction
        [Parameter(Mandatory=$false, Position = 1)]
        $BTId
    )
    Begin {
        Write-AppDLog "$(MyInvocation.MyCommand)"

        if ($MyInvocation.MyCommand.ParameterSets -contains 'AppName') {
            $AppId = (Get-AppDApplication -AppName $AppName).id
            if (!$AppId) {
                $msg = "Failed to find application with application name: $AppName"
                Write-AppDLog -Message $msg -Level 'Error'
                Throw $msg
            }
        }
    }
    Process
    {
        if ($BTId) {
            $BTs = (Get-AppDBTs -Appid $AppId).bts | Where-Object {$_.id -in $BTId}
        }
        else {
            $BTs = (Get-AppDBTs -Appid $AppId).bts
        }

        if (!$BTs) {
            $msg = "Failed to find business transactions"
            Write-AppDLog -Message $msg -Level 'Error'
            Throw $msg
        }

        foreach ($bt in $BTs) {
            $MetricPath = [System.Web.HttpUtility]::UrlEncode("$($bt.applicationComponentName)|$($bt.internalName)")
            Write-Output $MetricPath
        }
    }
}