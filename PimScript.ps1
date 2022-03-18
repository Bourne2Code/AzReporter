# PIM Provisioning Delay Script
#
# Purpose
#
# There is a lag between requesting a role, and provisioning
# There are no flags that we can look at to be sure provisioning is complete
# To test if the role has been provisioned, we will look for our user in the list of members for the role
#
# Requirements
#
# AzureADPreview module
# 1 user with PIM roles assigned / eligible
#
# We need to be able to use some of the attributes of the user requesting PIM.
# So capture the requestor's credentials and pass them to the connect cmdlet
#
$RequestorCreds = Get-Credential
Connect-AzureAD -Credential $RequestorCreds
#
#
# Show tenant detail and confirm user wants to continue.
#
Clear
Get-AzureADTenantDetail
#
Write-Host "PLEASE REVIEW - IF THIS DOES NOT LOOK LIKE THE RIGHT TENANT, BREAK THE SCRIPT!"
#
$Continue = Read-Host "Continue?"
$Continue.ToUpper()
If ($Continue -ne "Y")
{return}
#
#
# PIM commands use the requesting user's object ID as the SubjectID parameters
# PIM commands use the requesting user's tenant ID as the ResourceID parameters
# So, let's get these and stuff into variables
#
$RequestorUserObjectID = (Get-AzureADUser -ObjectId $RequestorCreds.UserName).ObjectID
$RequestorTenantID = (Get-AzureADTenantDetail).ObjectID
#
# We need to assign a role to the current user by a Role Definition [Template] ID.
# So we grab the list of Roles assigned to our user
#
$PIMRoleList = Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId $RequestorTenantID | Where-Object {$_.subjectID -eq $RequestorUserObjectID }
#
# There are no human readable display name for the roles.
# Role definiton IDs are found in the portal as the roles Template ID.
# We need this Template ID / Role ID to assign it to the user.
#
# Start by getting a list of eligible Roles for the user
# If none, we exit
# If only 1 Role exists, we use it
# If multiple Roles exist, we display the list and ask for input.
#
Switch ($PIMRoleList.count)
{
0 {
Write-Host "No Roles Available"
return
}
1 { $RoleTemplateID = $PIMRoleList.RoleDefinitionID }
Default {
$PIMRoleList
$RoleTemplateID = Read-Host "Enter the Role Template ID / Definition ID: "
}
}
#
# Create a schedule object for the time period we want PIM elevation to last.
# we start with the current time,
# We ask user how many minutes they need to be elevated,
# and set that as a specific end time.
#
$Duration = 60
Clear
Write-Host "Elevation is granted for a specific period of time measured in minutes."
Write-Host "."
$Duration = Read-Host "How many minutes would you like this role elevation to last?"
#
$Schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$Schedule.Type = "Once"
$Schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$Schedule.EndDateTime = ((Get-Date).AddMinutes($Duration)).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
#
# Ask for the PIM elevation
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' `
-ResourceId $RequestorTenantID `
-RoleDefinitionId $RoleTemplateID `
-SubjectId $RequestorUserObjectID `
-Type 'UserAdd' `
-AssignmentState 'Active' `
-schedule $Schedule `
-reason "PIM Delay Testing"
#
#
# Get the Azure AD role used in the PIM request.
# We can find it because the Role's TemplateId property is the same as the Role Definition paramater in PIM
#
$AADRole = Get-AzureADDirectoryRole | Where-Object {$_.RoleTemplateId -eq $RoleTemplateID}
#
#
# Test for role elevation
# Check the membership list of the AAD Role and see if our user is in the list.
# When we get the list of members, we use the where-object to only get the list of members
# that match our user's object ID.
# If the user is not in the list (count of objects = 0) then, wait one second and try again.
# We could add a pair of disconnect and connect statements to ensure we get a new token.
#
$count = 0
do {
$ActiveRoleList = Get-AzureADDirectoryRoleMember -ObjectId $AADRole.ObjectId | Where-Object {$_.ObjectId -eq $RequestorUserObjectID }
If ($ActiveRoleList.count -eq 0) {
$count ++
Write-Host "Attempt " $count
Start-Sleep -Seconds 1
}
}
while ($ActiveRoleList.count -eq 0)
#
# Now that we believe PIM has elevated the user, logout/login to refresh the token
Connect-AzureAD -Credential $RequestorCreds
#
# Display the end results
Write-Host "Your role is ready!"
Get-AzureADDirectoryRole -ObjectId $AADRole.ObjectId
Get-AzureADDirectoryRoleMember -ObjectId $AADRole.ObjectId
#
# Try to create a test user
$InitDomain = ((Get-AzureADTenantDetail).VerifiedDomains | Where-Object {$_.Initial -eq "True"}).Name
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = New-Guid
$TmpUsr = New-AzureADUser -AccountEnabled $false -DisplayName "Delete This User" -UserPrincipalName ("DeleteThisUser@" + $InitDomain) -PasswordProfile $PasswordProfile -MailNickName "DeleteThisUser"

