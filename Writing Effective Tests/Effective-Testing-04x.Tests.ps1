function Get-Number {
    return 0
}

function New-Number {
    param (
        [System.Int32] $Number
    )
    $testNumber = $Number / (Get-Number)
    if ($testNumber -eq 0) {
        throw 'Invalid'
    }
}
Describe 'Reinforced tests' {

    Context 'Room for improvement' {

        It 'should throw "Invalid" when "Number" is 0' {
            
            ## Assert
            { New-Number -Number 0 } | Should Throw
        }

    } #end Context

    Context 'Refactored' {

        It 'throws' {
            
            $result = New-Number | Should Be 0
        }

        It 'Divide by zero' {

            try {
                ## Act
                $result = 100 / 0

                ## Assert
                $result | Should Be 0
            }
            catch {
                ## Rethrow the terminating error including call stack
                throw
            }
            finally {
                ## Any clean up code can go here
            }

        }

    } #end Context
} #end Describe
