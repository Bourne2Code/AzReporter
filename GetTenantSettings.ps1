function Make-TH { 
	param (
        $tData
    )
	if ($tData -ne "") {
		$x = '  <th>' + $tData + '</th>'
	}
	else {
		$x = '  <th>&nbsp;</th>'
	}

	return $x
}

function Make-TD { 
	param (
        $tData
    )
	if ($tData -ne "") {
		$x = '  <td>' + $tData + '</td>'
	}
	else {
		$x = '  <td>&nbsp;</td>'
	}

	return $x
}

function Rpt-DirectorySettings {
# Get-AzureADDirectorySetting returns a collection of settion collections. 
# we will read each  setting collection into its own variable for processing
# Start by getting the entire collection. 
$ds = Get-AzureADDirectorySetting
# Then create an array of objects - 1 per setting collection in the entire collection.
$DirSettings = [Object[]]::new($ds.count)
#
#  DirSettings[0] is the first collection of settings. 
#  DirSettings[1] is the second collection of settings...

# Get The other source of tenant wide settings 
# This has a lot of fields that should be at the top of a tenant report
$td = Get-AzureADTenantDetail
#The privacy contact and url are in a collection - extract it. 
$prv = $td.PrivacyProfile

Add-Content -Path $RptName -Value ('<h1>Directory Settings</h1>')

Add-Content -Path $RptName -Value ('<h2>Directory - General Settings</h2>')
# start by writing the table of basic tenant settings
Add-Content -Path $RptName -Value '<table>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Display Name"))
Add-Content -Path $RptName -Value (Make-TD($td.DisplayName))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Object Id"))
Add-Content -Path $RptName -Value (Make-TD($td.ObjectId))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Object Type"))
Add-Content -Path $RptName -Value (Make-TD($td.ObjectType))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Technical Notification Mails"))
Add-Content -Path $RptName -Value (Make-TD($td.TechnicalNotificationMails))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Privacy Contact Email"))
Add-Content -Path $RptName -Value (Make-TD($prv.ContactEmail))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Privacy Statement URL"))
Add-Content -Path $RptName -Value (Make-TD($prv.StatementUrl))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("DirSync Enabled"))
Add-Content -Path $RptName -Value (Make-TD($td.DirSyncEnabled))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Last DirSync Time"))
Add-Content -Path $RptName -Value (Make-TD($td.CompanyLastDirSyncTime))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Street"))
Add-Content -Path $RptName -Value (Make-TD($td.Street))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("City"))
Add-Content -Path $RptName -Value (Make-TD($td.City))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("State"))
Add-Content -Path $RptName -Value (Make-TD($td.State))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("Country"))
Add-Content -Path $RptName -Value (Make-TD($td.Country))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("CountryLetterCode"))
Add-Content -Path $RptName -Value (Make-TD($td.CountryLetterCode))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("PostalCode"))
Add-Content -Path $RptName -Value (Make-TD($td.PostalCode))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("PreferredLanguage"))
Add-Content -Path $RptName -Value (Make-TD($td.PreferredLanguage))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value ' <tr>'
Add-Content -Path $RptName -Value (Make-TH("TelephoneNumber"))
Add-Content -Path $RptName -Value (Make-TD($td.TelephoneNumber))
Add-Content -Path $RptName -Value ' </tr>'
Add-Content -Path $RptName -Value '</table>'
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report VerifiedDomains
#
# -----------------------------------------------------------------------------------------------
# Get the collection of VerifiedDomains - it is a collection in a collection - too hard to loop through
$DomCollection = Get-AzureADTenantDetail| select VerifiedDomains
$Doms = $DomCollection[0].VerifiedDomains |sort-object -Property "Name"

# Write the VerifiedDomains table header
Add-Content -Path $RptName -Value ('<h2>Directory - Verified Domains</h2>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("Name") )
Add-Content -Path $RptName -Value (Make-TH("Type") )
Add-Content -Path $RptName -Value (Make-TH("Initial") )
Add-Content -Path $RptName -Value (Make-TH("Capabilities") )
Add-Content -Path $RptName -Value (Make-TH("_Default") )
Add-Content -Path $RptName -Value (Make-TH("User Count") )
Add-Content -Path $RptName -Value " </tr>"

# Write the VerifiedDomains table content
$i = 0
foreach ($_ in $Doms) {
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD($Doms[$i].Name) )
	Add-Content -Path $RptName -Value (Make-TD($Doms[$i].Type) )
	Add-Content -Path $RptName -Value (Make-TD($Doms[$i].Initial) )
	Add-Content -Path $RptName -Value (Make-TD($Doms[$i].Capabilities) )
	Add-Content -Path $RptName -Value (Make-TD($Doms[$i]._Default) )

$LikStr = "*" + ($Doms[$i].Name)
$UsrCnt = (Get-AzureADUser | Where-Object {$_.UserPrincipalName -like $LikStr}).count

	Add-Content -Path $RptName -Value (Make-TD($UsrCnt.ToString()) )

	Add-Content -Path $RptName -Value " </tr>"
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report VerifiedDomains
#
# -----------------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------------
#
# BEGIN - report Domains
#
# -----------------------------------------------------------------------------------------------
# Get the collection of Domains - it is a collection in a collection - too hard to loop through
$DomList = Get-AzureADDomain

# Write the Domains table header
Add-Content -Path $RptName -Value ('<h2>Directory - Domains</h2>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("Name") )
Add-Content -Path $RptName -Value (Make-TH("Is Verified") )
Add-Content -Path $RptName -Value (Make-TH("Is Root") )
Add-Content -Path $RptName -Value (Make-TH("Is Initial") )
Add-Content -Path $RptName -Value (Make-TH("Is Default") )
Add-Content -Path $RptName -Value (Make-TH("Is Default for Cloud Redirections") )
Add-Content -Path $RptName -Value (Make-TH("Authentication Type") )
Add-Content -Path $RptName -Value (Make-TH("Is Admin Managed") )
Add-Content -Path $RptName -Value (Make-TH("State") )
Add-Content -Path $RptName -Value (Make-TH("Availability Status") )
Add-Content -Path $RptName -Value " </tr>"

# Write the Domains table content
$i = 0
foreach ($_ in $Doms) {
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].Name) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].IsVerified) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].IsRoot) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].IsInitial) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].IsDefault) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].IsDefaultForCloudRedirections) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].AuthenticationType) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].IsAdminManaged) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].State) )
	Add-Content -Path $RptName -Value (Make-TD($DomList[$i].AvailabilityStatus) )
	Add-Content -Path $RptName -Value " </tr>"
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report Domains
#
# -----------------------------------------------------------------------------------------------



# -----------------------------------------------------------------------------------------------
#
# BEGIN - report SettingCollections
#
# -----------------------------------------------------------------------------------------------
# Loop through each of the collections of settings in $ds to copy them into their own variable.  
# Trying to access a collection within a collection is too hard! 
# Future loops can process one collection at a time

Add-Content -Path $RptName -Value ('<h2>Directory - Setting Collections</h2>')

$i = 0
foreach ($_ in $ds) {
	$DirSettings[$i] = $ds[$i]
	$i++
}

# Start writing the report.  
# Outer loop places DisplayName for the settings in a title
# Innter loop writes the settings values in a table format. 

for ($i = 0; $i -lt $ds.count; $i++) {
	# write the section title and table header
    Add-Content -Path $RptName -Value ('<h2>' + ($DirSettings[$i].DisplayName) + '</h2>')
    Add-Content -Path $RptName -Value '<table>'
    Add-Content -Path $RptName -Value ' <tr>'
    Add-Content -Path $RptName -Value (Make-TH("Config Item DisplayName"))
    Add-Content -Path $RptName -Value (Make-TH("Value"))
    Add-Content -Path $RptName -Value '</tr>'
	
	for ($k = 0; $k -lt $DirSettings[$i].Values.count; $k++) {
		# Write the current key/value pair as a table row
		Add-Content -Path $RptName -Value " <tr>"
		Add-Content -Path $RptName -Value (Make-TD($DirSettings[$i].Values[$k].Name) )
		Add-Content -Path $RptName -Value (Make-TD($DirSettings[$i].Values[$k].Value))
		Add-Content -Path $RptName -Value " </tr>"
	}
	# End of outer loop - close the table
	Add-Content -Path $RptName -Value "</table>"
}
# -----------------------------------------------------------------------------------------------
#
# END - report SettingCollections
#
# -----------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report AssignedPlans
#
# -----------------------------------------------------------------------------------------------
# The AssignedPlans collection is nested in the settings, so we pull it out into its own collection
$PlanCollection = Get-AzureADTenantDetail | select AssignedPlans
$Plans = $PlanCollection[0].AssignedPlans |sort-object -Property "Service"

# Write the AssignedPlans table
Add-Content -Path $RptName -Value ('<h2>Directory Settings - AssignedPlans</h2>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("AssignedTimestamp") )
Add-Content -Path $RptName -Value (Make-TH("CapabilityStatus") )
Add-Content -Path $RptName -Value (Make-TH("Service") )
Add-Content -Path $RptName -Value (Make-TH("ServicePlanId") )
Add-Content -Path $RptName -Value " </tr>"

$i = 0
foreach ($_ in $Plans) {
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD($Plans[$i].AssignedTimestamp) )
	Add-Content -Path $RptName -Value (Make-TD($Plans[$i].CapabilityStatus) )
	Add-Content -Path $RptName -Value (Make-TD($Plans[$i].Service) )
	Add-Content -Path $RptName -Value (Make-TD($Plans[$i].ServicePlanId) )
	Add-Content -Path $RptName -Value " </tr>"
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report AssignedPlans
#
# -----------------------------------------------------------------------------------------------

}

function Rpt-DirSync {
$dsc = Get-MsolDirSyncConfiguration
$dsf = Get-MsolDirSyncFeatures
$mco = Get-MsolCompanyInformation
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report DirSyncFeatures
#
# -----------------------------------------------------------------------------------------------

Add-Content -Path $RptName -Value ('<h1>DirSync / AD Connect</h1>')

# Write the CompanySettings table header

Add-Content -Path $RptName -Value ('<h2>Get-MsolCompanySettings</h2>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("MSOL Company Settings") )
Add-Content -Path $RptName -Value (Make-TH("Value") )
Add-Content -Path $RptName -Value " </tr>"

	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD("Last DirSync Time") )
	Add-Content -Path $RptName -Value (Make-TD($mco.LastDirSyncTime) )
	Add-Content -Path $RptName -Value " </tr>"
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD("Password Sync Enabled") )
	Add-Content -Path $RptName -Value (Make-TD($mco.PasswordSynchronizationEnabled) )
	Add-Content -Path $RptName -Value " </tr>"
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD("Last Password Sync Time") )
	Add-Content -Path $RptName -Value (Make-TD($mco.LastPasswordSyncTime) )
	Add-Content -Path $RptName -Value " </tr>"
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD("Last DirSync Time") )
	Add-Content -Path $RptName -Value (Make-TD($mco.LastDirSyncTime) )
	Add-Content -Path $RptName -Value " </tr>"
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD("DirSync Service Account") )
	Add-Content -Path $RptName -Value (Make-TD($mco.DirSyncServiceAccount) )
	Add-Content -Path $RptName -Value " </tr>"
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD("Self Service Password Reset Enabled") )
	Add-Content -Path $RptName -Value (Make-TD($mco.SelfServePasswordResetEnabled) )
	Add-Content -Path $RptName -Value " </tr>"
	Add-Content -Path $RptName -Value "</table>"


# Write the DirSyncFeatures table header

Add-Content -Path $RptName -Value ('<h2>Get-MsolDirSyncFeatures</h2>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("DirSyncFeature") )
Add-Content -Path $RptName -Value (Make-TH("Enabled") )
Add-Content -Path $RptName -Value " </tr>"


# Write the DirSyncFeatures table content
$i = 0
foreach ($_ in $dsf) {
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD($dsf[$i].DirSyncFeature) )
	Add-Content -Path $RptName -Value (Make-TD($dsf[$i].Enabled) )
	Add-Content -Path $RptName -Value " </tr>"
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report DirSyncFeatures
#
# -----------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report DirSyncConfiguration
#
# -----------------------------------------------------------------------------------------------

# Write the DirSyncFeatures table header

Add-Content -Path $RptName -Value ('<h2>Get-MsolDirSyncConfiguration</h2>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("ExtensionData") )
Add-Content -Path $RptName -Value (Make-TH("AccidentalDeletionThreshold") )
Add-Content -Path $RptName -Value (Make-TH("DeletionPreventionType") )
Add-Content -Path $RptName -Value " </tr>"

# Write the DirSyncFeatures table content
$i = 0
foreach ($_ in $dsc) {
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD($dsc[$i].ExtensionData) )
	Add-Content -Path $RptName -Value (Make-TD($dsc[$i].AccidentalDeletionThreshold) )
	Add-Content -Path $RptName -Value (Make-TD($dsc[$i].DeletionPreventionType) )
	Add-Content -Path $RptName -Value " </tr>"
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report DirSyncConfiguration
#
# -----------------------------------------------------------------------------------------------
	
}

function Rpt-DirectoryRoles {

Add-Content -Path $RptName -Value ('<h1>Directory Roles</h1>')
Add-Content -Path $RptName -Value ('<h2>Azure Directory Roles - assigned</h2>')
Add-Content -Path $RptName -Value ('<table>')

$roles = Get-AzureADDirectoryRole
foreach ($_ in $roles) {
  $roleName = ($_.DisplayName)
  $mbrs = Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId
  if ($mbrs.count -ne 0) {
    Add-Content -Path $RptName -Value " <tr>"
    Add-Content -Path $RptName -Value (Make-TH("Users w/ role: " + $roleName))
    Add-Content -Path $RptName -Value (Make-TH("Object Type"))
    Add-Content -Path $RptName -Value " </tr>"
    foreach ($_ in $mbrs) {
    Add-Content -Path $RptName -Value " <tr>"
	if ($_.ObjectType -eq "ServicePrincipal") {
        Add-Content -Path $RptName -Value (Make-TD($_.DisplayName))
		}
	else {
	    Add-Content -Path $RptName -Value (Make-TD($_.UserPrincipalName))
	}
    Add-Content -Path $RptName -Value (Make-TD($_.ObjectType))
    Add-Content -Path $RptName -Value " </tr>"
	}
  }
}
Add-Content -Path $RptName -Value " </tr>"
Add-Content -Path $RptName -Value " </table>"

Add-Content -Path $RptName -Value ('<h2>MS Office Directory Roles - assigned</h2>')
Add-Content -Path $RptName -Value ('<table>')

$roles = Get-MsolRole
foreach ($_ in $roles) {
$roleName = ($_.Name)
  $mbrs = Get-MsolRoleMember -RoleObjectId $_.ObjectId
  if ($mbrs.count -ne 0) {
    Add-Content -Path $RptName -Value " <tr>"
    Add-Content -Path $RptName -Value (Make-TH("Users w/ role: " + $roleName))
    Add-Content -Path $RptName -Value (Make-TH("Object Type"))
    Add-Content -Path $RptName -Value " </tr>"
    foreach ($_ in $mbrs) {
    Add-Content -Path $RptName -Value " <tr>"
	if ($_.RoleMemberType -eq "User"){
	    Add-Content -Path $RptName -Value (Make-TD($_.EmailAddress))
		Add-Content -Path $RptName -Value (Make-TD($_.RoleMemberType.ToString()))
	}
	else {
        Add-Content -Path $RptName -Value (Make-TD($_.DisplayName))
		Add-Content -Path $RptName -Value (Make-TD($_.RoleMemberType))
		}
    Add-Content -Path $RptName -Value " </tr>"
	}
  }
}

Add-Content -Path $RptName -Value " </tr>"
Add-Content -Path $RptName -Value " </table>"

}

$RptName = ".\TenantSettingsReport.html"

$rHeader = '<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Tenant Settings Report</title>
<style>
  table, th, td {
  border: 2px solid black;
  border-collapse: collapse;
}
  th, td {
  padding: .1em .5em;
}
  th {
  text-align: left;
}
</style>
</head>
<body>
<h1>Tenant Report for: ' + (Get-AzureADTenantDetail).DisplayName + '</h1>'

$rFooter = "</body>
</html>"

# Start by redirecting to a file
$rHeader > $RptName

Rpt-DirectorySettings

if ((Get-AzureADTenantDetail).DirSyncEnabled) {
	Rpt-DirSync
}

Rpt-DirectoryRoles
Add-Content -Path $RptName -Value $rFooter



#-------------------------------------------------------



$i = 0
foreach ($_ in $ds) {
	$DirSettings[$i] = $ds[$i]
	$i++
}

for ($i = 0; $i -lt $ds.count; $i++) {
	$rpt = "
 " + $DirSettings[$i].DisplayName + "
 Config Item DisplayName                                   Value
 ------------------------------------------------   -----"
	Add-Content -Path .\TenantSettings.html -Value $rpt
	
	for ($k = 0; $k -lt $DirSettings[$i].Values.count; $k++) {
		If ([string]::IsNullOrEmpty($DirSettings[0].Values[1].value)) {
			$val = $DirSettings[$i].Values[$k].Value
		}
		else {
			$val = ""
		}
		
		$rpt = " " + ($DirSettings[$i].Values[$k].Name).PadRight(50) + " " + $val
		Add-Content -Path .\TenantSettings.html -Value $rpt
	}
	
}

#-------------------------------------------------------

