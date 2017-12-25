function Get-AppDNodeMachines
{
    [CmdletBinding()]
    Param(
        $BaseUrl = (Get-AppDBaseUrl -controller 'Production'),
        $Auth = (Get-AppDAuth),
        $AppId = ((Get-AppDApplications).applications | Where-Object {$_.name -eq 'contoso'}).id,
        $toCsv,
        $destination
    )
    if(!$auth)
    {
        $auth = Get-AppDAuth
    }

    $AppDComputers = @()
    $results = Get-AppDApplicationDetail -auth $auth -baseUrl $baseUrl
    foreach ($result in $results) {
        if($result.Nodes.nodes.Name){
            $result.Nodes.nodes.Name | ForEach-Object  {
                $AppDComputers += [pscustomobject]@{
                    Application = $result.name
                    Name = $_.Split('-') | Select-Object -first 1 | Sort-Object -Unique -Descending
                }
            }
        }
    }

    Write-Output $AppDComputers

    if($toCsv)
    {
        $AppDComputers | ConvertTo-Csv -NoTypeInformation | Out-File $destination
    }
}