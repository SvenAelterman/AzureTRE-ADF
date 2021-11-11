$Location = 'southcentralus'

# Using a parameters object avoids the issue that "location" is specified twice as a parameter
$Parameters = @{
	location   = $Location
	azureTreId = 'tresc2021'
}

New-AzDeployment -TemplateFile .\main.bicep -Location $Location `
	-Name "adf-$(Get-Date -AsUTC -Format "yyyyMMddThhmmssZ")" `
	-TemplateParameterObject $Parameters