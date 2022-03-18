$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "1.P@ssW0rd.1"
$usrPrefix = "zUser"
$usrSuffix = "@NakedJeep.com"


for (($i = 1); ($i -lt 100); $i++) {
  $usrName = $usrPrefix
  $usrUPN = $usrPrefix + $i.ToString() + $usrSuffix

New-AzureADUser -DisplayName $usrName -PasswordProfile $PasswordProfile -UserPrincipalName $usrUPN -AccountEnabled $true -MailNickName $usrName
}

"zUser62@NakedJeep.com" -like "*NakedJeep.com"

Get-AzureADUser | Where-Object {$_.UserPrincipalName -contains "NakedJeep.com"}


ObjectId                             DisplayName UserPrincipalName               UserType
--------                             ----------- -----------------               --------
5e8b0f4d-2cd4-4e17-9467-b0f6a5c0c4d0 New user    NewUser@contoso.com             Member(Get-AzureADTenantDetail).PrivacyProfile

$roles = Get-AzureADDirectoryRole
foreach ($_ in $roles) {
  write-host ($_.DisplayName)
  $mbrs = Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId
  if ($mbrs.count -gt 0) {
    foreach ($_ in $mbrs) {
      write-host ($_.UserPrincipalName)
	}
  }
  write-host ($mbrs.count)
}

$roles = Get-MsolRole
foreach ($_ in $roles) {
$roleName = ($_.Name)
  $mbrs = Get-MsolRoleMember -RoleObjectId $_.ObjectId
  if ($mbrs.count -ne 0) {
    write-host "Users w/ role: " $roleName
    foreach ($_ in $mbrs) {
      write-host "Name: " ($_.DisplayName)
	}
  }
}

$roles = Get-MsolRole
foreach ($_ in $roles) {
  $roleName = ($_.Name)
  $mbrs = Get-MsolRoleMember -RoleObjectId $_.ObjectId
  if ($mbrs.count -ne 0) {
    write-host ("Users w/ role: " + ($roleName))
    foreach ($_ in $mbrs) {
	  if ($_.ObjectType -eq "User"){
	    write-host "User ObjectID"
	    write-host ($_.ObjectID)
	    write-host ($_.EmailAddress)
		write-host ($_.RoleMemberType)
	  }
	  else {
	    write-host "SP ObjectID"
	    write-host ($_.ObjectID)
        write-host ($_.DisplayName)
		write-host ($_.RoleMemberType)
	  }
	}
  }
}

$mbrs = Get-MsolRoleMember -RoleObjectId 62e90394-69f5-4237-9190-012177145e10

