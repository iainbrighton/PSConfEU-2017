function Add-Number {
    param (
        [System.Int32] $A,
        [System.Int32] $B
    )
    return ($A + $B)
}

Describe 'ModuleName\Add-Number' {

    It 'given "1" and "2" should return "3"' {

        ## Arrange
        $expected = 3

        ## Act
        $result = Add-Number -A 1 -B 2

        ## Assert
        $result | Should Be $expected
    }

} #end describe
