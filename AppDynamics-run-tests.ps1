try
{
    $currentLocation = Split-Path -parent $MyInvocation.MyCommand.Path
    if (!(Get-Module Pester)) {
        Install-Module -Name Pester -Force
        Import-Module -Name Pester
    }

    Invoke-Pester "$currentLocation\Tests\" -OutputFile All.TestResults.xml -OutputFormat NUnitXml -ExcludeTag Smoke
}
catch
{
    Write-Output "Error Occurred: $($_)"
    $_
    Exit 1
}