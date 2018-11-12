# http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx

Import-Module ActiveDirectory
NEW-ADOrganizationalUnit -name "Groups"

NEW-ADOrganizationalUnit -name "People"

Import-CSV -delimiter "," c:\vagrant\scripts\users_ad.csv | foreach {
  New-ADUser -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.Surname -Name $_.Name -EmailAddress $_.mail -Title $_.title -Company $_.company -Department $_.department `
             -Path "ou=People,dc=trivadislabs,dc=com" `
             -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -Enabled $true
}

New-ADGroup -Name "Human Resources" -SamAccountName "Human Resources" -GroupCategory Security -GroupScope Global -DisplayName "Human Resources" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Human Resources" -Member lynd
Add-ADGroupMember -Identity "Human Resources" -Member rider

New-ADGroup -Name "Information Technology" -SamAccountName "Information Technology" -GroupCategory Security -GroupScope Global -DisplayName "Information Technology" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Information Technology" -Member tanner
Add-ADGroupMember -Identity "Information Technology" -Member gartner
Add-ADGroupMember -Identity "Information Technology" -Member fleming

New-ADGroup -Name "Trivadis LAB Users" -SamAccountName "Trivadis LAB Users" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Users" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member lynd
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member rider
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member tanner
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member gartner
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member fleming
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member bond
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member walters
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member renton
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member leitner
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member blake
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member turner
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member ward
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member moneypenny
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member scott
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member smith
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member adams
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member ford
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member blofeld
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member miller
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member clark
Add-ADGroupMember -Identity "Trivadis LAB Users" -Member king

New-ADGroup -Name "Trivadis LAB DB Admins" -SamAccountName "Trivadis LAB DB Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB DB Admins" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB DB Admins" -Member gartner
Add-ADGroupMember -Identity "Trivadis LAB DB Admins" -Member fleming

New-ADGroup -Name "Trivadis LAB Developers" -SamAccountName "Trivadis LAB Developers" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB Developers" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Member scott
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Member smith
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Member adams
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Member ford
Add-ADGroupMember -Identity "Trivadis LAB Developers" -Member blofeld

New-ADGroup -Name "Trivadis LAB System Admins" -SamAccountName "Trivadis LAB System Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB System Admins" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Trivadis LAB System Admins" -Member tanner
Add-ADGroupMember -Identity "Trivadis LAB System Admins" -Member fleming

New-ADGroup -Name "Trivadis LAB APP Admins" -SamAccountName "Trivadis LAB APP Admins" -GroupCategory Security -GroupScope Global -DisplayName "Trivadis LAB APP Admins" -Path "OU=Groups,DC=trivadislabs,DC=com"

New-ADGroup -Name "Accounting" -SamAccountName "Accounting" -GroupCategory Security -GroupScope Global -DisplayName "Accounting" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Accounting" -Member miller
Add-ADGroupMember -Identity "Accounting" -Member clark

New-ADGroup -Name "Research" -SamAccountName "Research" -GroupCategory Security -GroupScope Global -DisplayName "Research" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Research" -Member scott
Add-ADGroupMember -Identity "Research" -Member smith
Add-ADGroupMember -Identity "Research" -Member adams
Add-ADGroupMember -Identity "Research" -Member ford
Add-ADGroupMember -Identity "Research" -Member blofeld

New-ADGroup -Name "Sales" -SamAccountName "Sales" -GroupCategory Security -GroupScope Global -DisplayName "Sales" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Sales" -Member blake
Add-ADGroupMember -Identity "Sales" -Member turner
Add-ADGroupMember -Identity "Sales" -Member ward
Add-ADGroupMember -Identity "Sales" -Member moneypenny

New-ADGroup -Name "Operations" -SamAccountName "Operations" -GroupCategory Security -GroupScope Global -DisplayName "Operations" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Operations" -Member bond
Add-ADGroupMember -Identity "Operations" -Member walters
Add-ADGroupMember -Identity "Operations" -Member renton
Add-ADGroupMember -Identity "Operations" -Member leitner

New-ADGroup -Name "Senior Management" -SamAccountName "Senior Management" -GroupCategory Security -GroupScope Global -DisplayName "Senior Management" -Path "OU=Groups,DC=trivadislabs,DC=com"
Add-ADGroupMember -Identity "Senior Management" -Member king
Add-ADGroupMember -Identity "Senior Management" -Member rider
Add-ADGroupMember -Identity "Senior Management" -Member fleming
Add-ADGroupMember -Identity "Senior Management" -Member clark
Add-ADGroupMember -Identity "Senior Management" -Member blofeld
Add-ADGroupMember -Identity "Senior Management" -Member moneypenny
Add-ADGroupMember -Identity "Senior Management" -Member leitner
