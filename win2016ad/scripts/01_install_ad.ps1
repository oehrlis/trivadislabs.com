# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 01_install_ad.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to install Active Directory Role
# Notes......: ...
# Reference..: 
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# processing commandline parameter
param (
    [string]$domain = "trivadislabs.com",
    [string]$DomainMode = "Win2012R2",
    [string]$ip = "10.0.0.4",
    [string]$dns1 = "8.8.8.8",
    [string]$dns2 = "4.4.4.4",
    [string]$PlainPassword
 )

# - Variables ---------------------------------------------------------------
# set file name for default password
$DefaultPWDFile="C:\vagrant\config\default_pwd_win2016ad.txt"

# set default value for netbiosDomain if empty
$netbiosDomain = $domain.ToUpper() -replace "\.\w*$",""

# define list of asci values for passwords
$asci = [char[]]([char]40..[char]57) + ([char]33, [char]58,[char]95) + ([char]65..[char]90) + ([char[]]([char]97..[char]122))

# generate random password if variable is empty
if (!$PlainPassword) { 
    # get default password from file
    if ((Test-Path $DefaultPWDFile)) {
        Write-Host "Get default password from $DefaultPWDFile"
        $PlainPassword=Get-Content -Path  $DefaultPWDFile -TotalCount 1
        $PlainPassword=$PlainPassword.trim()
        # generate a password if password from file is empty
        if (!$PlainPassword) {
            Write-Host "Default password from $DefaultPWDFile seems empty, generate new password"
            $PlainPassword = (1..$(Get-Random -Minimum 8 -Maximum 10) | % {$asci | get-random}) -join "" 
        }
    } else {
        # generate a new password
        Write-Error "Generate new password"
        $PlainPassword = (1..$(Get-Random -Minimum 8 -Maximum 10) | % {$asci | get-random}) -join "" 
    }  
} else {
    Write-Host "Using password provided via vagrant config"
}
# write passwort to Vagrant config folder
Write-Host "Write default password to $DefaultPWDFile"
Set-Content $DefaultPWDFile $PlainPassword

# define subnet based on ip
$subnet = $ip -replace "\.\w*$", ""
# - EOF Variables -----------------------------------------------------------

# - Main --------------------------------------------------------------------
Write-Host '= Start setup part 01 ======================================'
Write-Host "Domain              : $domain"
Write-Host "Domain Mode         : $DomainMode"
Write-Host "IP                  : $ip"
Write-Host "DNS 1               : $dns1"
Write-Host "DNS 2               : $dns2"
Write-Host "Default Password    : $PlainPassword"
Write-Host '- Installing RSAT tools ------------------------------------'

# initiate AD setup if system is not yet part of a domain
if ((gwmi win32_computersystem).partofdomain -eq $false) {

    Import-Module ServerManager
    Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter,RSAT-ADDS-Tools

    Write-Host '- Relax password complexity --------------------------------'
    # Disable password complexity policy
    secedit /export /cfg C:\secpol.cfg
    (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
    secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\secpol.cfg -confirm:$false

    # Set administrator password
    $computerName = $env:COMPUTERNAME
    $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
    $adminUser.SetPassword($PlainPassword)

    $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    
    Write-Host '- Creating domain controller -------------------------------'
    # Create AD Forest for Windows Server 2012 R2
    Install-WindowsFeature AD-domain-services
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -SafeModeAdministratorPassword $SecurePassword `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode $DomainMode `
        -ForestMode $DomainMode `
        -DomainName $domain `
        -DomainNetbiosName $netbiosDomain `
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$true `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true

    Write-Host '- Configure network adapter --------------------------------'
    $newDNSServers = $dns1, $dns2
    $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
    if ($adapters) {
        Write-Host Setting DNS
        $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}
    }
}
Write-Host '= Finish part 01 ==========================================='
# --- EOF --------------------------------------------------------------------