$openai_org_id = ""
$openai_api_key = ""
$startString = "2023-01-01"
$endString = "2023-12-31"

##############################################################################################################

$origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, ([System.DateTimeKind]::Utc)
$format = "yyyy-MM-dd"
$start = [DateTime]::ParseExact($startString, $format, $null)
$end = [DateTime]::ParseExact($endString, $format, $null)

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$users = Invoke-WebRequest -UseBasicParsing -Uri "https://api.openai.com/v1/organizations/$openai_org_id/users" `
-WebSession $session `
-Headers @{
"method"="GET"
  "authority"="api.openai.com"
  "scheme"="https"
  "path"="/v1/organizations/$openai_org_id/users"
  "authorization"="Bearer $openai_api_key"
}
$your_users = @()
foreach ($line in ($users.Content | Out-String | ConvertFrom-JSON)) {
      $your_users += $line.members.data.user | Select-Object id,name,email
}
$firstTime = $true
for ($day = $start; $day -le $end; $day = $day.AddDays(1)) {
	$formated_day = Get-Date $day -Format "yyyy-MM-dd"
	$formated_day
	Remove-Item -Path "out/$formated_day.csv"
	$firstTime = $true
	foreach ($user in $your_users){
		$id_of_user = $user.id
		$success = $false
		while (-not $success) {
			try {
				"https://api.openai.com/v1/usage?date=$formated_day&user_public_id=$id_of_user"
				$data = Invoke-WebRequest -UseBasicParsing -Uri "https://api.openai.com/v1/usage?date=$formated_day&user_public_id=$id_of_user" `
					-WebSession $session `
					-Headers @{
						"method"="GET"
						"authority"="api.openai.com"
						"authorization"="Bearer $openai_api_key"
						"openai-organization"=$openai_org_id
					}
				$success = $true
			}
			catch {
				Write-Output "Request failed. Retrying..."
				Start-Sleep -Seconds 5  # Wait for 5 seconds before retrying
			}
		}

		
		foreach ($line in ($data.Content | Out-String | ConvertFrom-JSON)) {
			foreach ($model_use in $line.data) {
				$model_use | Add-Member -NotePropertyName "email" -NotePropertyValue $user.email
				$model_use | Add-Member -NotePropertyName "aggregation_date" -NotePropertyValue (Get-Date -Date ($origin.AddSeconds($model_use.aggregation_timestamp))).ToString("yyyy-MM-dd")
				$model_use | Add-Member -NotePropertyName "aggregation_time" -NotePropertyValue (Get-Date -Date ($origin.AddSeconds($model_use.aggregation_timestamp))).ToString("HH:mm:ss")
				if ($firstTime) {
					Add-Content -Path "out/$formated_day.csv" -Value (($model_use[0].PSObject.Properties.Name | ForEach-Object { "`"$_`"" }) -join ',')
					$firstTime = $false
				}
				Add-Content -Path "out/$formated_day.csv" -Value ($model_use | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1)
			}
		}
	}
}
