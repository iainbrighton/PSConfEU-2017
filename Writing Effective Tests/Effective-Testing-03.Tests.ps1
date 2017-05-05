function Get-FakeObject {
    param ( )
    return [PSCustomObject] @{ Name = 'Fake Object'; Description = 'We love Pester'; }
}

Describe 'refactor using object equivalence' {
    
    Context 'Room for improvement' {

        It 'expected object should equal fake object' {
            ## Arrange
            $expected = @{ Name = 'Fake Object'; Description = 'We love Pester'; }

            ## Act
            $result = Get-FakeObject

            $result.Name | Should Be $expected.Name
            $result.Description | Should Be $expected.Description
        }

    } #end Context

    Context 'Refactored' {

        It 'expected object should equal fake object' {
            
            ## Arrange
            $expected = [PSCustomObject] @{ Name = 'Fake Object'; Description = 'We love Pester'; }

            ## Act
            $result = Get-FakeObject

            ## Assert
            $compareObjectParams = @{
                ReferenceObject = $expected;
                DifferenceObject = $result;
                Property = 'Name','Description';
                CaseSensitive = $true;
            }
            Compare-Object @compareObjectParams | Should BeNullOrEmpty

        }

    } #end Context
} #end Describe
