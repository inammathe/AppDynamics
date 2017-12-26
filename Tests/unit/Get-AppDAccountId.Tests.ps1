$moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$mockDataLocation = "$moduleLocation\Tests\mock_data"
$module = 'AppDynamics'

Get-Module AppDynamics | Remove-Module
Import-Module "$moduleLocation\$module.psd1"

InModuleScope $module {
    $function = 'Get-AppDAccountId'
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation" {
            $mockDataLocation = "$moduleLocation\Tests\mock_data"
            $env:AppDURL = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountID = $null

            Mock Invoke-RestMethod -MockWith {
                $mockData = @"
                <Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>System.Management.Automation.PSCustomObject</T>
      <T>System.Object</T>
    </TN>
    <MS>
      <S N="id">2</S>
      <S N="name">customer1</S>
      <Obj N="links" RefId="1">
        <TN RefId="1">
          <T>System.Object[]</T>
          <T>System.Array</T>
          <T>System.Object</T>
        </TN>
        <LST>
          <Obj RefId="2">
            <TNRef RefId="0" />
            <MS>
              <S N="href">http://appdynamics.contoso.com:8090/controller/api/accounts/2/apikey</S>
              <S N="name">apikey</S>
            </MS>
          </Obj>
          <Obj RefId="3">
            <TNRef RefId="0" />
            <MS>
              <S N="href">http://appdynamics.contoso.com:8090/controller/api/accounts/2/licensemodules</S>
              <S N="name">licensemodules</S>
            </MS>
          </Obj>
          <Obj RefId="4">
            <TNRef RefId="0" />
            <MS>
              <S N="href">http://appdynamics.contoso.com:8090/controller/api/accounts/2/users</S>
              <S N="name">users</S>
            </MS>
          </Obj>
          <Obj RefId="5">
            <TNRef RefId="0" />
            <MS>
              <S N="href">http://appdynamics.contoso.com:8090/controller/api/accounts/2/applications</S>
              <S N="name">applications</S>
            </MS>
          </Obj>
        </LST>
      </Obj>
    </MS>
  </Obj>
</Objs>
"@
                return [System.Management.Automation.PSSerializer]::DeserializeAsList($mockData)
            }
            $AccountId = Get-AppDAccountId

            It "$function returns an id that is not null or empty" {
                $AccountId | Should -not -BeNullOrEmpty
            }
            It "$function returns an id that is a string" {
                $AccountId -is [string] | Should -Be $true
            }
            It "$function returns an id that is greater than 0" {
                [int]$AccountId -ge 0 | Should -Be $true
            }
            It "$function calls invoke-restmethod and is only invoked once" {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -Exactly
            }
        }
    }
}