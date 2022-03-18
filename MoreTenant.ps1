$dsc = Get-MsolDirSyncConfiguration
$dsf = Get-MsolDirSyncFeatures

# -----------------------------------------------------------------------------------------------
#
# BEGIN - report DirSyncFeatures
#
# -----------------------------------------------------------------------------------------------

# Write the DirSyncFeatures table header

Add-Content -Path $RptName -Value ('<h1>Get-MsolDirSyncFeatures</h1>')
Add-Content -Path $RptName -Value ('<table>')
Add-Content -Path $RptName -Value " <tr>"
Add-Content -Path $RptName -Value (Make-TH("DirSyncFeature") )
Add-Content -Path $RptName -Value (Make-TH("ExtensionData") )
Add-Content -Path $RptName -Value (Make-TH("Enabled") )
Add-Content -Path $RptName -Value " </tr>"

# Write the DirSyncFeatures table content
$i = 0
foreach ($_ in $dsf) {
	Add-Content -Path $RptName -Value " <tr>"
	Add-Content -Path $RptName -Value (Make-TD($dsf[$i].DirSyncFeature) )
	Add-Content -Path $RptName -Value (Make-TD($dsf[$i].ExtensionData) )
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

Add-Content -Path $RptName -Value ('<h1>Get-MsolDirSyncConfiguration</h1>')
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
ExtensionData               : System.Runtime.Serialization.ExtensionDataObject
AccidentalDeletionThreshold : 99999
DeletionPreventionType      : EnabledForCount

