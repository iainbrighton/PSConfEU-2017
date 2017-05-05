<#
    .SYNOPSIS
        Creates a virtualised AD controller and Nano Server infrastructure
        for a Hyper-Converged 
#>
configuration HyperConvergedBaseline {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsServerCore
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    Import-DscResource -ModuleName xActiveDirectory;
    Import-DscResource -ModuleName xDnsServer;
    Import-DscResource -ModuleName xNetworking;
    Import-DscResource -ModuleName xComputerManagement;
    Import-DscResource -ModuleName xHyper-V;
    Import-DscResource -ModuleName xCredSSP;

    # $domainName = $AllNodes.Where 
    $domainControllerNodeName = $AllNodes.Where({ $_.Role -eq 'Controller' }).NodeName;
    $domainControllerDomainName = $AllNodes.Where({ $_.Role -eq 'Controller' }).DomainName;
    $domainControllerFqdn = '{0}.{1}' -f $domainControllerNodeName, $domainControllerDomainName;
    # $domainControllerNodeName, $Node.DomainName;

    node $AllNodes.NodeName {

        LocalConfigurationManager {

            RebootNodeIfNeeded = $true;
            ConfigurationMode = 'ApplyOnly';
            DebugMode = 'ForceModuleImport';
        }
    }

    node $AllNodes.Where({ $_.Role -eq 'Controller' }).NodeName {

        $features = @(
            'DNS',
            'AD-Domain-Services',
            'RSAT-AD-PowerShell',
            'RSAT-AD-AdminCenter',
            'RSAT-ADDS',
            'RSAT-AD-Tools',
            'RSAT-Role-Tools',
            'RSAT-DNS-Server',
            'RSAT-Clustering',
            'RSAT-Clustering-PowerShell',
            'RSAT-Clustering-AutomationServer',
            'RSAT-Clustering-CmdInterface'
            'RSAT-Hyper-V-Tools',
            'Hyper-V-PowerShell'
        )
        foreach ($feature in $features) {

            WindowsFeature $($feature.Replace('-','')) {
                Ensure = 'Present';
                Name   = $feature;
            }

        } #end foreach

        if ($IsServerCore) {

            Registry 'DefaultPowerShell' {
                Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon';
                ValueName = 'Shell';
                ValueData = 'PowerShell.exe -NoExit';
                Ensure    = 'Present';
            }

        }

        xIPAddress 'IPAddress' {
            IPAddress      = $Node.IPAddress;
            InterfaceAlias = $Node.InterfaceAlias;
            PrefixLength   = $Node.PrefixLength;
            AddressFamily  = $Node.AddressFamily;
        }

        xDefaultGatewayAddress 'DefaultGateway' {
            InterfaceAlias = $Node.InterfaceAlias;
            AddressFamily  = $Node.AddressFamily;
            Address        = $Node.DefaultGateway;
        }

        File 'DomainBlobs' {
            DestinationPath = 'C:\{0}' -f $Node.DomainBlobFolder;
            Type = 'Directory';
            Ensure = 'Present';
        }

        xADDomain 'ADDomain' {
            DomainName = $node.DomainName;
            SafemodeAdministratorPassword = $Credential;
            DomainAdministratorCredential = $Credential;
            DependsOn = '[xIPAddress]IPAddress','[WindowsFeature]ADDomainServices','[WindowsFeature]DNS';
        }

        ## Reverse lookup zone
        $ipQuartets = $node.IPAddress.Split('.')
        xDnsServerPrimaryZone 'ReverseLookup' {
            Name = '{0}.{1}.{2}.in-addr.arpa' -f $ipQuartets[2], $ipQuartets[1], $ipQuartets[0];
            DynamicUpdate = 'NonsecureAndSecure';
            DependsOn = '[xADDomain]ADDomain';
        }

        foreach ($nodeName in $AllNodes.Where({ $_.Role -eq 'ClusterNode' }).NodeName) {
        
            xADComputer $nodeName {
                ComputerName = $nodeName;
                RequestFile = 'C:\{0}\{1}' -f $Node.DomainBlobFolder, $nodeName;
            }
            
        }

        xCredSSP 'CredSSPServer' {
            Role   = 'Server';
            Ensure = 'Present';
        }

    } #end role Controller

    node $AllNodes.Where({ $_.Role -eq 'ClusterNode' }).NodeName {

        xIPAddress 'IPAddress' {
            IPAddress      = $Node.IPAddress;
            InterfaceAlias = $Node.InterfaceAlias;
            PrefixLength   = $Node.PrefixLength;
            AddressFamily  = $Node.AddressFamily;
        }

        xDNSServerAddress 'DnsServerAddress' {
            InterfaceAlias = $Node.InterfaceAlias;
            AddressFamily  = $Node.AddressFamily;
            Address        = $Node.DnsServer;
        }

        xDefaultGatewayAddress 'DefaultGateway' {
            InterfaceAlias = $Node.InterfaceAlias;
            AddressFamily  = $Node.AddressFamily;
            Address        = $Node.DefaultGateway;
        }

        WaitForAll 'DomainBlob' {
            ResourceName      = '[xADComputer]{0}' -f $Node.NodeName;
            NodeName          = $domainControllerFqdn;
            RetryIntervalSec  = 15;
            RetryCount        = 40;
        }

        ## Convert credential into a domain\username credential. Assume it's already qualified
        $domainQualifiedUsername = $credential.GetNetworkCredential().UserName;
        $credentialDomainName = $credential.GetNetworkCredential().Domain;
        if (([System.String]::IsNullOrEmpty($credentialDomainName)) -or ($credentialDomainName -eq '~')) {

            $domainQualifiedUsername = '{0}\{1}' -f $Node.DomainName.Split('.')[0], $credential.GetNetworkCredential().UserName;
        }
        $domainCredential = New-Object -TypeName PSCredential -ArgumentList @($domainQualifiedUsername, $credential.Password);

        xOfflineDomainJoin 'OfflineDomainJoin' {
            IsSingleInstance     = 'Yes';
            RequestFile          = '\\{0}\C$\{1}\{2}' -f $domainControllerNodeName, $Node.DomainBlobFolder, $Node.NodeName;
            PsDscRunAsCredential = $domainCredential;
            DependsOn            = '[WaitForAll]DomainBlob'
        }

        xVMSwitch 'ManagementvSwitch' {
            Name              = 'Management';
            Type              = 'External';
            NetAdapterName    = $Node.InterfaceAlias;
            AllowManagementOS = $true;
        }
        
    } #end role ClusterNode

}
