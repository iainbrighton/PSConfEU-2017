function Get-FakeObject {
    param ( )
    return [PSCustomObject] @{ Name = 'Fake Object'; Description = 'We love Pester'; }
}

Describe 'refactor using parameterised tests' {

    Context 'Room for improvement' {

        It 'object name and description should be "Fake Object" and "We love Pester"' {
            ## Arrange
            $expected = @{ Name = 'Fake Object'; Description = 'We love Pester'; }

            ## Act
            $result = Get-FakeObject

            $result.Name | Should Be $expected.Name
            $result.Description | Should Be $expected.Description
        }

    } #end Context

    Context 'Refactored' {
        
        It "object '<ParameterName>' should be '<ExpectedValue>'" -TestCases @(
    
            @{ ParameterName = 'Name'; ExpectedValue = 'Fake Object'; }
            @{ ParameterName = 'Description'; ExpectedValue = 'We love Pester'; }

        ) -Test {

            param (
                $ParameterName,
                $ExpectedValue
            )

            ## Act
            $result = Get-FakeObject

            ## Assert
            $result.$ParameterName | Should Be $ExpectedValue
    
        }

    } #end Context
} #end Describe
