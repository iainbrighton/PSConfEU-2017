##########################################################
#################
#################                Setup
#################
##########################################################

$trustedHosts = '10.*','192.168.*','*.lab.local','LABHOST';
Enable-PSRemoting -Force -SkipNetworkProfileCheck -Verbose
Enable-WSManCredSSP -DelegateComputer $trustedHosts -Role Client -Force -Verbose
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value ([System.String]::Join(',', $trustedHosts));

## Create the 'Computer Configuration\Administrative Templates\System\Credentials Delegation\Allow delegating fresh credentials with NTLM-only server authentication' local policy keys
$credentialsDelegationPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation';
$credentialsDelegationKeyName = 'AllowFreshCredentialsWhenNTLMOnly';
$null = New-ItemProperty -Path $credentialsDelegationPath -Name $credentialsDelegationKeyName -Value 1 -PropertyType DWORD -Force;
$null = New-Item -Path "$credentialsDelegationPath\$credentialsDelegationKeyName" -Type Container -Force -ErrorAction SilentlyContinue;

$hostCount = 1;
foreach ($trustedHost in $trustedHosts) {

	## Add each host to the AllowFreshCredentialsWithNTLMOnly key
	$null= New-ItemProperty -Path "$credentialsDelegationPath\$credentialsDelegationKeyName" -Name $hostCount -Value "wsman/$trustedHost" -PropertyType String -Force
    $hostCount++;
}


##########################################################
#################
#################            Hyper-Converged
#################
##########################################################

Set-Location -Path '~\OneDrive\Documents\PSConfEU-2017\Deploying Nano Server with Lability';

Invoke-LabResourceDownload -ConfigurationData .\HyperConverged.psd1 -DSCResources -Verbose
Clear-ModulePath -Scope CurrentUser -Force -Verbose
Install-LabModule -ConfigurationData .\HyperConverged.psd1 -ModuleType DscResource -Scope CurrentUser -Verbose
. .\HyperConvergedBaseline.ps1
HyperConvergedBaseline -ConfigurationData .\HyperConverged.psd1 -Credential Administrator -Verbose

## For berevity - just provision the CONTROLLER VM
Reset-LabVM -Name DC -ConfigurationData .\HyperConverged.psd1 -Path .\HyperConvergedBaseline -Credential Administrator -NoSnapshot -Verbose | Start-VM
## Wait for AD completion, stop and snapshot baseline configuration
Wait-Lab -ComputerName 10.200.0.10 -Credential LAB\Administrator -Verbose
Stop-Lab -ConfigurationData .\HyperConverged.psd1 -Verbose -ErrorAction SilentlyContinue
Checkpoint-Lab -ConfigurationData .\HyperConverged.psd1 -SnapshotName 'PSConfEU Baseline' -Verbose -ErrorAction SilentlyContinue

## Start AD domain controller, provision the NANO servers, wait for completion, stop and snapshot pre cluster deployment
Start-Lab -ConfigurationData .\HyperConverged.psd1 -Verbose -ErrorAction SilentlyContinue
Reset-LabVM -Name NANO1,NANO2,NANO3 -ConfigurationData .\HyperConverged.psd1 -Path .\HyperConvergedBaseline -Credential Administrator -NoSnapshot -Verbose | Start-VM
Wait-Lab -ConfigurationData .\HyperConverged.psd1 -Credential LAB\Administrator -PreferNodeProperty IPAddress -Verbose
Stop-Lab -ConfigurationData .\HyperConverged.psd1 -Verbose -ErrorAction SilentlyContinue
Checkpoint-Lab -ConfigurationData .\HyperConverged.psd1 -SnapshotName 'PSConfEU Pre S2D' -Verbose -ErrorAction SilentlyContinue

## Start lab
Start-Lab -ConfigurationData .\HyperConverged.psd1 -Verbose
## Compile hyper-converged Nano cluster resources
. .\HyperConverged.ps1
HyperConverged -ConfigurationData .\HyperConverged.psd1 -Credential LAB\Administrator -Verbose

## CredSSP for the double hop..
$controller = New-PSSession -ComputerName 10.200.0.10 -Credential LAB\Administrator -Authentication CredSSP
Copy-Item -Path .\HyperConverged\* -ToSession $controller -Destination C:\Users\Administrator\Documents -Verbose
Enter-PSSession -Session $controller
Invoke-Command -Session $controller -ScriptBlock {
    Start-DscConfiguration -Path .\ -Wait -Verbose -Force;
}

## Revert for testing purposes
Restore-Lab -ConfigurationData .\HyperConverged.psd1 -SnapshotName 'PSConfEU Pre S2D' -Force -Verbose

