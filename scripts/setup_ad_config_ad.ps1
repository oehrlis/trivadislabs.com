# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: setup_ad_config_ad.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to configure Active Directory Domain
# Notes......: ...
# Reference..: https://github.com/StefanScherer/adfs2
#              http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
#              http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Write-Host 'Wait 30 seconds to get AD Domain ready...'
        Start-Sleep -Seconds 30
    }
}

# - Variables ---------------------------------------------------------------
$adDomain = Get-ADDomain
$domain = $adDomain.DNSRoot
$domainDn = $adDomain.DistinguishedName
$usersAdPath = "ou=People,$domainDn"
$groupAdPath = "ou=Groups,$domainDn"
$password = ConvertTo-SecureString -AsPlainText 'LAB01schulung' -Force
# - EOF Variables -----------------------------------------------------------

# - Configure Domain --------------------------------------------------------
Import-Module ActiveDirectory

# add People OU...
Write-Host 'Add organizational units for departments...'
NEW-ADOrganizationalUnit -name "People" -path $domainDn
NEW-ADOrganizationalUnit -name "Senior Management" -path $usersAdPath
NEW-ADOrganizationalUnit -name "Human Resources" -path $usersAdPath
NEW-ADOrganizationalUnit -name "Information Technology" -path $usersAdPath 
NEW-ADOrganizationalUnit -name "Accounting" -path $usersAdPath
NEW-ADOrganizationalUnit -name "Research" -path $usersAdPath
NEW-ADOrganizationalUnit -name "Sales" -path $usersAdPath
NEW-ADOrganizationalUnit -name "Operations" -path $usersAdPath

#...and import users
Write-Host 'Import users from CSV ...'
Import-CSV -delimiter "," users_ad.csv | foreach {
    $Path = "ou=" + $_.Department + "," + $usersAdPath
    $UserPrincipalName = $_.SamAccountName + "@" + $domain
    $eMail = $_.GivenName + "." + $_.Surname + "@" + $domain
    New-ADUser  -SamAccountName $_.SamAccountName  `
                -GivenName $_.GivenName `
                -Surname $_.Surname `
                -Name $_.Name `
                -UserPrincipalName $UserPrincipalName `
                -DisplayName $_.Name `
                -EmailAddress $eMail `
                -Title $_.Title `
                -Company $_.Company `
                -Department $_.Department `
                -Path $Path `
                -AccountPassword $password -Enabled $true
}

# Update OU and set managedBy
Write-Host 'Add managed by to organizational units...'
Set-ADOrganizationalUnit -Identity "ou=Senior Management,$usersAdPath" -ManagedBy king
Set-ADOrganizationalUnit -Identity "ou=Human Resources,$usersAdPath" -ManagedBy rider
Set-ADOrganizationalUnit -Identity "ou=Information Technology,$usersAdPath" -ManagedBy fleming
Set-ADOrganizationalUnit -Identity "ou=Accounting,$usersAdPath" -ManagedBy clark
Set-ADOrganizationalUnit -Identity "ou=Research,$usersAdPath" -ManagedBy blofeld
Set-ADOrganizationalUnit -Identity "ou=Sales,$usersAdPath" -ManagedBy moneypenny
Set-ADOrganizationalUnit -Identity "ou=Operations,$usersAdPath" -ManagedBy leitner

# create Trivadis LAB groups
Write-Host 'Create Trivadis LAB groups...'
NEW-ADOrganizationalUnit -name "Groups" -path $domainDn
New-ADGroup -Name "Trivadis LAB Users" -SamAccountName "Trivadis LAB Users" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Users" -Path $groupAdPath
Add-ADGroupMember -Identity "Trivadis LAB Users" -Members lynd,rider,tanner,gartner,fleming,bond,walters,renton,leitner,blake,turner,ward,moneypenny,scott,smith,adams,ford,blofeld,miller,clark,king

New-ADGroup -Name "Trivadis LAB DB Admins" -SamAccountName "Trivadis LAB DB Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB DB Admins" -Path $groupAdPath
Add-ADGroupMember -Identity "Trivadis LAB DB Admins" -Members gartner,fleming

New-ADGroup -Name "Trivadis LAB Developers" -SamAccountName "Trivadis LAB Developers" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Developers" -Path $groupAdPath
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Members scott,smith,adams,ford,blofeld

New-ADGroup -Name "Trivadis LAB System Admins" -SamAccountName "Trivadis LAB System Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB System Admins" -Path $groupAdPath
Add-ADGroupMember -Identity "Trivadis LAB System Admins" -Members tanner,fleming

New-ADGroup -Name "Trivadis LAB APP Admins" -SamAccountName "Trivadis LAB APP Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB APP Admins" -Path $groupAdPath

New-ADGroup -Name "Trivadis LAB Management" -SamAccountName "Trivadis LAB Management" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Management" -Path $groupAdPath
Add-ADGroupMember -Identity "Trivadis LAB Management" -Members king,rider,fleming,clark,blofeld,moneypenny,leitner

# create service principle
Write-Host 'Create service principles...'
New-ADUser -SamAccountName "oracle18c" -Name "oracle18c" -UserPrincipalName "oracle18c@trivadislabs.com" -DisplayName "oracle18c" -Path "cn=Users,$domainDn" -AccountPassword $password -Enabled $true
New-ADUser -SamAccountName "db.trivadislabs.com" -Name "db.trivadislabs.com" -DisplayName "db.trivadislabs.com" -UserPrincipalName "oracle\db.trivadislabs.com@trivadislabs.com" -Path "cn=Users,$domainDn" -AccountPassword $password -Enabled $true
Write-Host 'Done configuring AD...'
# --- EOF --------------------------------------------------------------------