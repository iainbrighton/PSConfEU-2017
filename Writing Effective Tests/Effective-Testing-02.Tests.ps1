Describe 'Multiple asserts' {

   It 'multiple asserts could be testing multiple concerns' {
       
        Write-Host " This asserion will throw"
        $true | Should Be $false
        Write-Host " This will never execute and you'll never know if the following assertion ever worked!"
        $false | Should Be $true
    }

}
