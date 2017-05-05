@{
    AllNodes = @(

        @{
            NodeName                    = '*';
            DomainName                  = 'lab.local';
            InterfaceAlias              = 'Ethernet';
            PrefixLength                = 24;
            DefaultGateway              = '10.200.0.2';
            DnsServer                   = '10.200.0.10';
            AddressFamily               = 'IPv4';
            DomainBlobFolder            = 'DomainBlobs';
            PSDscAllowDomainUser        = $true;

            # Lability_SwitchName         = 'Internal vSwitch'; ##TODO: Change to NAT
            Lability_SwitchName         = 'NAT'; ##TODO: Change to NAT
            Lability_ProcessorCount     = 2;
            Lability_StartupMemory      = 2GB;
            Lability_BootDelay          = 30;
        }
        @{
            NodeName                    = 'DC';
            Role                        = 'Controller';
            IPAddress                   = '10.200.0.10';
            DnsServer                   = '127.0.0.1';
            PsDscAllowPlainTextPassword = $true;

            Lability_BootOrder          = 10;
            Lability_Media              = '2016_x64_Standard_EN_Eval';
        }
        @{
            NodeName                    = 'NANO1';
            Role                        = 'ClusterNode'
            IPAddress                   = '10.200.0.11';
            PsDscAllowPlainTextPassword = $true;

            Lability_BootOrder          = 20;
            Lability_Media              = '2016_x64_Datacenter_Nano_HyperConverged_EN_Eval';
            Lability_ProcessorOption    = @{ ExposeVirtualizationExtensions = $true; }
            Lability_NetworkOption      = @{ MacAddressSpoofing = $true; }
            Lability_HardDiskDrive      = @( @{ Type = 'VHDX'; MaximumSizeBytes = 50GB; }
                                             @{ Type = 'VHDX'; MaximumSizeBytes = 50GB; } );
        }
        @{
            NodeName                    = 'NANO2';
            Role                        = 'ClusterNode';
            IPAddress                   = '10.200.0.12';
            PsDscAllowPlainTextPassword = $true;

            Lability_BootOrder          = 20;
            Lability_Media              = '2016_x64_Datacenter_Nano_HyperConverged_EN_Eval';
            Lability_ProcessorOption    = @{ ExposeVirtualizationExtensions = $true; }
            Lability_NetworkOption      = @{ MacAddressSpoofing = $true; }
            Lability_HardDiskDrive      = @( @{ Type = 'VHDX'; MaximumSizeBytes = 50GB; }
                                             @{ Type = 'VHDX'; MaximumSizeBytes = 50GB; } );
        }
        @{
            NodeName                    = 'NANO3';
            Role                        = 'ClusterNode';
            IPAddress                   = '10.200.0.13';
            PsDscAllowPlainTextPassword = $true;

            Lability_BootOrder          = 20;
            Lability_Media              = '2016_x64_Datacenter_Nano_HyperConverged_EN_Eval';
            Lability_ProcessorOption    = @{ ExposeVirtualizationExtensions = $true; }
            Lability_NetworkOption      = @{ MacAddressSpoofing = $true; }
            Lability_HardDiskDrive      = @( @{ Type = 'VHDX'; MaximumSizeBytes = 50GB; }
                                             @{ Type = 'VHDX'; MaximumSizeBytes = 50GB; } );
        }

    ) #end AllNodes

    NonNodeData = @{
        Lability = @{

            EnvironmentPrefix = 'HC-';

            Media = @(

                @{  Id              = '2016_x64_Datacenter_Nano_HyperConverged_EN_Eval';
	                Filename        = '2016_x64_EN_Eval.iso';
	                Description     = 'Windows Server 2016 Datacenter Nano Hyper-Converged 64bit English Evaluation';
	                Architecture    = 'x64';
	                ImageName       = 'Windows Server 2016 SERVERDATACENTERNANO';
	                MediaType       = 'ISO';
	                OperatingSystem = 'Windows';
	                Uri             = 'http://download.microsoft.com/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO';
	                Checksum        = '18A4F00A675B0338F3C7C93C4F131BEB';
                    Hotfixes        = @(
                                        @{  ## Cumulative Update 19/03/2017
                                            Id = 'Windows10.0-KB4015438-x64.msu';
                                            Uri = 'http://download.windowsupdate.com/d/msdownload/update/software/updt/2017/03/windows10.0-kb4015438-x64_c0e4b528d1c6b75503efd12d44d71a809c997555.msu'; }
                                       )
	                CustomData      = @{
                        ## DefaultShell  = 'powershell.exe'; ## Developer mode ;)
                        SetupComplete = 'CoreCLR';
	                	PackagePath   = '\NanoServer\Packages';
	                	PackageLocale = 'en-US';
	                	WimPath       = '\NanoServer\NanoServer.wim';
	                	Package       = @('Microsoft-NanoServer-Guest-Package',
	                		              'Microsoft-NanoServer-DSC-Package',
	                		              'Microsoft-NanoServer-FailoverCluster-Package',
	                		              'Microsoft-NanoServer-Storage-Package',
	                		              'Microsoft-NanoServer-Compute-Package');
	                } #end CustomData
                } #end 2016_x64_Datacenter_Nano_Converged_EN_Eval
            )

            Network = @(

                @{  Name = 'NAT';
                    Type = 'Internal'; }

            ) #end Network

            DSCResource = @(

                @{ Name = 'xActiveDirectory'; RequiredVersion = '2.16.0.0'; }
                @{ Name = 'xNetworking'; RequiredVersion = '3.2.0.0'; }
                @{ Name = 'xComputerManagement'; RequiredVersion = '1.9.0.0'; }
                @{ Name = 'xDNSServer'; RequiredVersion = '1.7.0.0'; }
                @{ Name = 'xCredSSP'; RequiredVersion = '1.1.0.0'; } ## https://github.com/PowerShell/xCredSSP/issues/16
                @{ Name = 'xHyper-V'; Provider = 'GitHub'; Owner = 'iainbrighton'; Branch = 'PSConfEu'; RequiredVersion = '3.7.2.0'; }
                @{ Name = 'NanoCluster'; Provider = 'GitHub'; Owner = 'iainbrighton'; RequiredVersion = '1.0.3'; }

            )

        } #end Lability
    } #end NonNodeData
} #end Configuration
