# http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx


$BaseDN = 'dc=trivadislabs,dc=com'

Import-Module ActiveDirectory

# add People OU and import users
NEW-ADOrganizationalUnit -name "People" -path $BaseDN
NEW-ADOrganizationalUnit -name "Senior Management" -path "ou=People,dc=trivadislabs,dc=com"
NEW-ADOrganizationalUnit -name "Human Resources" -path "ou=People,dc=trivadislabs,dc=com"
NEW-ADOrganizationalUnit -name "Information Technology" -path "ou=People,dc=trivadislabs,dc=com" 
NEW-ADOrganizationalUnit -name "Accounting" -path "ou=People,dc=trivadislabs,dc=com"
NEW-ADOrganizationalUnit -name "Research" -path "ou=People,dc=trivadislabs,dc=com"
NEW-ADOrganizationalUnit -name "Sales" -path "ou=People,dc=trivadislabs,dc=com"
NEW-ADOrganizationalUnit -name "Operations" -path "ou=People,dc=trivadislabs,dc=com"
Import-CSV -delimiter "," c:\vagrant\scripts\users_ad.csv | foreach {
    $Path = "ou=" + $_.Department + ",ou=People,dc=trivadislabs,dc=com"
    New-ADUser -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.Surname -Name $_.Name -EmailAddress $_.mail -Title $_.Title -Company $_.Company -Department $_.Department `
             -Path $Path `
             -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -Enabled $true
}

# set OU managedBy
Set-ADOrganizationalUnit -Identity "ou=Senior Management,ou=People,dc=trivadislabs,dc=com" -ManagedBy king
Set-ADOrganizationalUnit -Identity "ou=Human Resources,ou=People,dc=trivadislabs,dc=com" -ManagedBy rider
Set-ADOrganizationalUnit -Identity "ou=Information Technology,ou=People,dc=trivadislabs,dc=com" -ManagedBy fleming
Set-ADOrganizationalUnit -Identity "ou=Accounting,ou=People,dc=trivadislabs,dc=com" -ManagedBy clark
Set-ADOrganizationalUnit -Identity "ou=Research,ou=People,dc=trivadislabs,dc=com" -ManagedBy blofeld
Set-ADOrganizationalUnit -Identity "ou=Sales,ou=People,dc=trivadislabs,dc=com" -ManagedBy moneypenny
Set-ADOrganizationalUnit -Identity "ou=Operations,ou=People,dc=trivadislabs,dc=com" -ManagedBy leitner

# create Trivadis LAB groups
NEW-ADOrganizationalUnit -name "Groups" -path "dc=trivadislabs,dc=com"
New-ADGroup -Name "Trivadis LAB Users" -SamAccountName "Trivadis LAB Users" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Users" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB Users" -Members lynd,rider,tanner,gartner,fleming,bond,walters,renton,leitner,blake,turner,ward,moneypenny,scott,smith,adams,ford,blofeld,miller,clark,king

New-ADGroup -Name "Trivadis LAB DB Admins" -SamAccountName "Trivadis LAB DB Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB DB Admins" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB DB Admins" -Members gartner,fleming

New-ADGroup -Name "Trivadis LAB Developers" -SamAccountName "Trivadis LAB Developers" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Developers" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Members scott,smith,adams,ford,blofeld

New-ADGroup -Name "Trivadis LAB System Admins" -SamAccountName "Trivadis LAB System Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB System Admins" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB System Admins" -Members tanner,fleming

New-ADGroup -Name "Trivadis LAB APP Admins" -SamAccountName "Trivadis LAB APP Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB APP Admins" -Path "OU=Groups,DC=trivadislabs,DC=com"

New-ADGroup -Name "Trivadis LAB Management" -SamAccountName "Trivadis LAB Management" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Management" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB Management" -Members king,rider,fleming,clark,blofeld,moneypenny,leitner