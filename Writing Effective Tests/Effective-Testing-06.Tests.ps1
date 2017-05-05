function TestMe { }

Describe 'Default Mock scope' {

    Context 'Room for improvement' {

        Mock TestMe { Write-Host "   TestMe: Context" -ForegroundColor Yellow }

        It 'should call "TestMe" function only once' {

            Mock TestMe { Write-Host "   TestMe: It" -ForegroundColor Yellow }

            TestMe

            Assert-MockCalled TestMe -Exactly 1

        }

        It 'should call "TestMe" function only once' {

            Mock TestMe { Write-Host "   TestMe: It" -ForegroundColor Yellow }

            TestMe

            Assert-MockCalled TestMe -Exactly 1

        }

        It 'should call "TestMe" function only once' {

            TestMe

            Assert-MockCalled TestMe -Exactly 1

        }

    } #end Context

    Context 'Refactored' {

        Mock TestMe { Write-Host "   TestMe: Context" -ForegroundColor Yellow }

        It 'should call "TestMe" function only once' {

            Mock TestMe { Write-Host "   TestMe: It" -ForegroundColor Yellow }

            TestMe

            Assert-MockCalled TestMe -Exactly 1 -Scope It

        }

        It 'should call "TestMe" function only once' {

            Mock TestMe { Write-Host "   TestMe: It" -ForegroundColor Yellow }

            TestMe

            Assert-MockCalled TestMe -Exactly 1 -Scope It

        }

        It 'should call "TestMe" function only once' {

            TestMe

            Assert-MockCalled TestMe -Exactly 1 -Scope It

        }

    } #end Context

}
