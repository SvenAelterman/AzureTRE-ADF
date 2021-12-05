$Location = 'southcentralus'

# Using a parameters object avoids the issue that "location" is specified twice as a parameter
$Parameters = @{
	location    = $Location
	azureTreId  = 'tresc2021'
	# Padded with 4 spaces because I don't know the actual workspace ID
	workspaceId = '    marc'
}

New-AzDeployment -TemplateFile .\main.bicep -Location $Location `
	-Name "storage-$(Get-Date -AsUTC -Format "yyyyMMddThhmmssZ")" `
	-TemplateParameterObject $Parameters

# TODO: Capture output and start new ADF triggers (can't be done with Bicep/ARM)