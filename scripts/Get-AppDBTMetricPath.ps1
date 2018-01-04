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
        # Mandatory application ID.
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        $AppId,

        # Use the name of the application if you do not know the AppId
        [Parameter(Mandatory=$false)]
        $AppName,

        # Optional Id of a business transaction
        [Parameter(Mandatory=$false)]
        $BTId
    )
    Begin {
        Write-AppDLog "$($MyInvocation.MyCommand)"
    }
    Process
    {
        $AppId = Test-AppId -AppDId $AppId -AppDName $AppName

        # Get Business transactions
        if ($BTId) {
            $BTs = (Get-AppDBTs -Appid $AppId) | Where-Object {$_.id -in $BTId}
        }
        else {
            $BTs = (Get-AppDBTs -Appid $AppId)
        }

        if (!$BTs) {
            $msg = "Failed to find business transactions"
            Write-AppDLog -Message $msg -Level 'Error'
            Throw $msg
        }

        foreach ($bt in $BTs) {
            $MetricPath = [System.Net.WebUtility]::UrlEncode("$($bt.applicationComponentName)|$($bt.internalName)")
            Write-Output $MetricPath
        }
    }
}