# This script runs in Windows integrated authentication.
# Make sure script is running under an account with privileges to access target sql database instance

#max characters defined for Invoke-Sqlcmd which will truncate result at 4k otherwise
$maxResultLength = 30000 

#set the source and target servers 

#sourceServer = where we get the environment configuration from
$sourceServer = "AMTST46SQL05.az.fox.afg"

#targetServer = the target SQL instance where we want to re-create the environment
#               configuration settings.
$targetServer = "localhost"

#$folder = The name of the SSISDB child folder name.
#          Only use folder name one level deep from the parent SSISDB node.
#          e.g. for EPS\Projects\enrollment-processing the folder to use would be EPS
$folder = "IssuerDisputesETL"

#env = the environment configuration source and target name
$env = "TEST"

#$CreateEnvQuery = the query to the stored procedure that will generate he environment
#                  configuration script to be run on the target SQL instance
$CreateEnvQuery = 

"
USE master
DECLARE	@return_value int,
		@script varchar(max)

EXEC	@return_value = [dbo].[pDeploy_SSIS_ScriptEnvironment_ver_4]
		@folder = $folder,
		@env = $env,
		@script = @script OUTPUT

SELECT	@script as N'@script'

SELECT	'Return Value' = @return_value
"

#Invoke the storedproc on the source SQL instance
$result = Invoke-Sqlcmd -ServerInstance $sourceServer -Database DisputesDb -Query $CreateEnvQuery -MaxCharLength $maxResultLength

#Convert $result.script which is an object[] array into a proper string
$createEnvScript = $result.script | Out-String

#write the environment creation script to the console for debugging purposes
Write-Host $createEnvScript

#save the environment creation script if needed
$result.script | Out-File c:\scripts\$folder.sql

#run the environment creation script on the target machine to create the environment configuration pulled from the source server
Invoke-Sqlcmd -ServerInstance $targetServer -Database Master -Query $createEnvScript -MaxCharLength $maxResultLength
