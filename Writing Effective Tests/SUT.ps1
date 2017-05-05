function SUT
{
    param
    (
        [Int] $InputA,
        [Int] $InputB,
        [Switch] $InverseOutput
    )
    if ($InverseOutput)
    {
        $result = Get-SUTOutput -NumberA $InputA -NumberB $InputB
    }
    else
    {
        $result = Get-SUTOutput -NumberA $InputB -NumberB $InputA
    }
    return $result
}
