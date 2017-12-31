$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$moduleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDAuth Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation (`$UserName -eq 'guest@customer1', `$Password -eq 'guest')" {
            # Prepare
            $UserName = 'guest@customer1'
            $Password = 'guest'
            $AuthString = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName + ":" + $Password )))
            Mock Write-AppDLog -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            # Act
            $mockData = Get-AppDAuth

            # Assert
            It "returns data that is not null or empty" {
                $mockData | Should -not -BeNullOrEmpty
            }
            It "Returns the expected type" {
                $mockData -is [string] | Should -Be $true
            }
            It "Returns the expected value" {
                $mockData | Should -BeExactly $AuthString
            }
            It "Write-AppDLog invoked only once" {
                Assert-MockCalled -CommandName Write-AppDLog -Times 1 -Exactly
            }
        }

        Context "$AppDFunction return value validation (`$UserName -eq `mockUserName, `$Password -eq `mockPassword)" {
            # Prepare
            $UserName = 'mockUserName'
            $Password = 'mockPassword'
            $AuthString = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName + '@customer1' + ':' + $Password )))


            Mock Write-AppDLog -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            # Act
            $result = Get-AppDAuth -UserName $UserName -Password $Password

            # Assert
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected type" {
                $result -is [string] | Should -Be $true
            }
            It "Returns the expected value" {
                $result | Should -BeExactly $AuthString
            }
            It "Write-AppDLog invoked only once" {
                Assert-MockCalled -CommandName Write-AppDLog -Times 1 -Exactly
            }
            It "Appends @customer1 to the username if not supplied" {
                $AuthStringBad = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName + ':' + $Password )))
                $result | Should -not -Be $AuthStringBad
                $result.Length -gt $AuthStringBad.Length| Should -Be $true
            }
        }
    }
}