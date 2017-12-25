<#
.Synopsis
   This function gets the data of the variables $env:AppDURl and $env:AppDAuth that are used by all the cmdlets of the Octoposh module
.DESCRIPTION
   This function gets the data of the variables $env:AppDURl and $env:AppDAuth that are used by all the cmdlets of the Octoposh module
.EXAMPLE
   Get-AppDConnectionInfo

   Get the current connection info. Its the same as getting the values of $env:AppDURL and $Env:AppDAuth
.LINK
   Github project: ghttps://github.com/Dalmirog/Octoposh
#>
function Get-AppDConnectionInfo
{
    Begin
    {
        
    }
    Process
    {
        $properties = [ordered]@{
            AppDURl = $env:AppDURl
            AppDAuth = $env:AppDAuth
            AppDAccountId = $env:AppDAccountId
        }

        $o =  new-object psobject -Property $properties
    }
    End
    {

        return $o

    }
}