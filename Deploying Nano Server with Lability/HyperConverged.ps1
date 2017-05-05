<#
    .SYNOPSIS
        Creates a Hyper-Converged Nano Server Cluster.
#>
configuration HyperConverged {
    param (
        [Parameter()]
        [System.String] $DomainName = 'lab.local',
        
        [Parameter()]
        [System.String] $ClusterName = 'hcnano',

        [Parameter()]
        [System.String] $StaticAddress = '10.200.0.50',

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    Import-DscResource -ModuleName xHyper-V;
    Import-DscResource -ModuleName NanoCluster;

    $clusterNodesFqdn = $AllNodes.Where({ $_.Role -eq 'ClusterNode' }).NodeName |
        ForEach-Object {
            if ($_.Contains('.')) { $_; }
            else { '{0}.{1}' -f $_, $DomainName; }
        } ;

    $clusterFqdn = '{0}.{1}' -f $ClusterName, $DomainName;

    node $AllNodes.Where({ $_.Role -eq 'ClusterNode' }).NodeName {

        xVMHost 'Hyper-V-Host' {
            IsSingleInstance          = 'Yes';
            EnableEnhancedSessionMode = $true;
            VirtualHardDiskPath       = 'C:\ClusterStorage\Volume1';
            VirtualMachinePath        = 'C:\ClusterStorage\Volume1';
        }

    } #end clusternode
    
    node $AllNodes.Where({ $_.Role -eq 'Controller' }).NodeName {

        NanoCluster $ClusterName {
            ClusterName   = $clusterFqdn;
            StaticAddress = $StaticAddress;
            ClusterNode   = $clusterNodesFqdn;
            Credential    = $Credential;
        }

        WaitForNanoCluster $ClusterName {
            ClusterName   = $clusterFqdn;
            Credential    = $Credential;
            DependsOn     = "[NanoCluster]$ClusterName";
        }

        NanoClusterS2D $ClusterName {
            ClusterName           = $clusterFqdn;
            Credential            = $Credential;
            CacheState            = 'Disabled';
            SkipEligibilityChecks = $true;
            DependsOn             = "[WaitForNanoCluster]$ClusterName";
        }

        NanoClusterS2DVolume $ClusterName {
            ClusterName             = $clusterFqdn;
            StoragePoolFriendlyName = 'S2D*';
            FriendlyName            = 'S2D';
            Credential              = $Credential;
            FileSystem              = 'CSVFS_ReFS';
            PhysicalDiskRedundancy  = 1;
            ResiliencySettingName   = 'Parity';
            MediaType               = 'HDD'
            DependsOn               = "[NanoClusterS2D]$ClusterName";
        }

    } #end controller

} #end configuration
