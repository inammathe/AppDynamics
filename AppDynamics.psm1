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
        $VerbosePreference = 'Continue'
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
    Invoke-RestMethod -Method Get -Uri "$env:AppDURL/$uri" -Headers $connectionInfo.header -Verbose:$false
}

#region Utility functions
#endregion