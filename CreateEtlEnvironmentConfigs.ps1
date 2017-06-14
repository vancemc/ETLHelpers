# This script runs in Windows integrated authentication.
# Make sure script is running under an account with privileges to access target sql database instance

$maxResultLength = 30000 #max characters defined for Invoke-Sqlcmd which will truncate result at 4k otherwise

$server = "AMTST46SQL05.az.fox.afg"

$folder = "IssuerDisputesETL"
$env = "TEST"

$CreateEnvQuery = 

"
DECLARE	@return_value int,
		@script varchar(max)

EXEC	@return_value = [dbo].[pDeploy_SSIS_ScriptEnvironment_ver_4]
		@folder = $folder,
		@env = $env,
		@script = @script OUTPUT

SELECT	@script as N'@script'

SELECT	'Return Value' = @return_value
"

$result = Invoke-Sqlcmd -ServerInstance AMTST46SQL05.az.fox.afg -Database DisputesDb -Query $CreateEnvQuery -MaxCharLength $maxResultLength

Write-Host $result.script

$result.script | Out-File c:\scripts\$folder.sql
