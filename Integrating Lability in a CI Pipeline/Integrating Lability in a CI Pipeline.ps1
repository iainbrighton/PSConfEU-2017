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


#####################################################################################
##########
##########                         Continuous Integration
##########    See https://github.com/iainbrighton/xActiveDirectory/tree/PSConfEU
##########
#####################################################################################
