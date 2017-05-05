<#
    Install-Module -Name Indented.StubCommand
    Get-Command -Name Test-DnsServer | New-StubCommand | Set-Clipboard
#>

function Test-DnsServer {
    [CmdletBinding(DefaultParameterSetName='Context', PositionalBinding=$false)]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance[]])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#DnsServerValidity')]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance[]])]
    [OutputType('Microsoft.Management.Infrastructure.CimInstance#DnsServerValidity')]
    param (
        [Parameter(ParameterSetName='ZoneMaster', Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Context', Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateNotNull()]
        [ipaddress[]]
        ${IPAddress},
        
        [Parameter(ParameterSetName='ZoneMaster')]
        [Parameter(ParameterSetName='Context')]
        [Alias('Cn')]
        [ValidateNotNullOrEmpty()]
        [ValidateNotNull()]
        [ValidateLength(1, 255)]
        [string]
        ${ComputerName},
        
        [Parameter(ParameterSetName='Context', Position=2)]
        [ValidateSet('DnsServer','Forwarder','RootHints')]
        [ValidateNotNullOrEmpty()]
        [ValidateNotNull()]
        [string]
        ${Context},
        
        [Parameter(ParameterSetName='ZoneMaster', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateNotNull()]
        [string]
        ${ZoneName},
        
        [Parameter(ParameterSetName='ZoneMaster')]
        [Parameter(ParameterSetName='Context')]
        [Alias('Session')]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimSession[]]
        ${CimSession},
        
        [Parameter(ParameterSetName='ZoneMaster')]
        [Parameter(ParameterSetName='Context')]
        [int]
        ${ThrottleLimit},
        
        [Parameter(ParameterSetName='ZoneMaster')]
        [Parameter(ParameterSetName='Context')]
        [switch]
        ${AsJob}
    )
    
}

Describe 'Stubbing Commands' {

    It 'Should call "Test-DnsServer" with "RootHints" context' {
        
        Mock Test-DnsServer { }

        Test-DnsServer -IPAddress '8.8.8.8' -Context RootHints

        Assert-MockCalled Test-DnsServer -ParameterFilter { $Context -eq 'RootHints' } -Scope It
    }
}
