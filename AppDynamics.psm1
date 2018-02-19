<#
 Function to load all external scripts/functions under the $PSScriptRoot\Scripts directory
#>
Write-Verbose 'Loading external scripts'

$scripts = Get-ChildItem $PSScriptRoot\scripts -Filter "*.ps1"

foreach ($script in $scripts){
. $script.FullName
}

Export-ModuleMember $scripts.BaseName
Write-Verbose 'External scripts Loaded'

#region Logging functions
function Write-AppDLog
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [Alias('LogPath')]
        [string]$Path='C:\Logs\AppDynamics-Powershell.log',

        [Parameter(Mandatory=$false)]
        [ValidateSet("Error","Warn","Info")]
        [string]$Level="Info",

        [Parameter(Mandatory=$false)]
        [switch]$NoClobber
    )

    Begin
    {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    Process
    {

        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
            }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            New-Item $Path -Force -ItemType File | Out-Null
            }

        else {
            # Nothing to see here yet.
            }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
                }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
                }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
                }
            }

        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End
    {
    }
}
#endregion

#region Helper Functions. These wont get exported by the module, but will be available to be used by the exported cmdlets
function Put-AppDResource( [string]$uri, [object]$resource, [object]$connectionInfo) {
    Write-AppDLog "$($MyInvocation.MyCommand)`turi:$uri`n`tbody:$resource"
    Invoke-RestMethod -Method Put -Uri "$env:AppDURL/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $connectionInfo.header -Verbose:$false
}

function Post-AppDResource([string]$uri, [object]$resource, [object]$connectionInfo) {
    Write-AppDLog "$($MyInvocation.MyCommand)`turi:$uri`n`tbody:$resource"
    Invoke-RestMethod -Method Post -Uri "$env:AppDURL/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $connectionInfo.header -Verbose:$false
}

function Get-AppDResource([string]$uri, [object]$connectionInfo) {
    Write-AppDLog "$($MyInvocation.MyCommand)`turi:$uri"
    Invoke-RestMethod -Method Get -Uri (Join-Parts -Separator '/' -Parts $env:AppDURL,$uri) -Headers $connectionInfo.header -Verbose:$false
}

function Test-AppId
{
    [CmdletBinding()]
    param(
        $AppDId,
        $AppDName
    )

    Write-AppDLog -Message "Validating AppId..."
    $AppId = @()
    if($AppDId) {
        foreach ($id in $AppDId) {
            $AppId += (Get-AppDApplication -AppId $AppDId -ErrorAction SilentlyContinue).Id
        }
    }
    elseif ($AppDName -and -not $AppDId) {
        foreach ($name in $AppDName) {
            $AppId += (Get-AppDApplication -AppName $name -ErrorAction SilentlyContinue).Id
        }
    }
    elseif (-not $AppDId -and -not $AppDName)
    {
        $AppId = (Get-AppDApplication -ErrorAction SilentlyContinue).Id
    }

    if (!$AppId) {
        $msg = "Failed to find application : ($AppDId|$AppDName)"
        Write-AppDLog -Message $msg -Level 'Error'
        Exit 1
    }
    Write-Output $AppId
}

function Join-Parts
{
    param
    (
        $Parts = $null,
        $Separator = ''
    )

    ($Parts | Where-Object { $_ } | ForEach-Object {
         ([string]$_).trim($Separator)
    } | Where-Object { $_ }) -join $Separator
}

function ConvertTo-EpochTime
{
    param
    (
        [Parameter(Mandatory)]
        [datetime]$datetime,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Days',
            'Hours',
            'Minutes',
            'Seconds',
            'Milliseconds')]
        $format = 'MilliSeconds'
    )

    $timeSpan = (New-TimeSpan -Start (Get-Date -Date "01/01/1970") -End $datetime)
    switch ($format) {
        Days            { [MATH]::Floor($timeSpan.TotalDays) }
        Hours           { [MATH]::Floor($timeSpan.TotalHours) }
        Minutes         { [MATH]::Floor($timeSpan.TotalMinutes) }
        Seconds         { [MATH]::Floor($timeSpan.TotalSeconds) }
        Milliseconds    { [MATH]::Floor($timeSpan.TotalMilliseconds) }
    }
}

function ConvertFrom-EpochTime
{
    param
    (
        [Parameter(Mandatory)]
        [long]$epochTime,

        #AppDynamics Stores their timespamps in milliseconds
        [Parameter(Mandatory=$false)]
        [ValidateSet('Days',
            'Hours',
            'Minutes',
            'Seconds',
            'Milliseconds')]
        $format = 'MilliSeconds',

        #AppDynamics Stores their timespamps in UTC
        [Parameter(Mandatory=$false)]
        [switch]
        $ToLocalTime
    )
    $epoch = Get-Date -Date '01/01/1970'
    switch ($format) {
        Days            { $result = $epoch.AddDays($epochTime) }
        Hours           { $result = $epoch.AddHours($epochTime) }
        Minutes         { $result = $epoch.AddMinutes($epochTime) }
        Seconds         { $result = $epoch.AddSeconds($epochTime) }
        Milliseconds    { $result = $epoch.AddMilliseconds($epochTime) }
    }
    if ($ToLocalTime) {
        [timezone]::CurrentTimeZone.ToLocalTime($result)
    }
    else {
        $result
    }
}
#endregion