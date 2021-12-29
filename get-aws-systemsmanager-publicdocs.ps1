Import-Module -Name AWS.Tools.SimpleSystemsManagement
Set-DefaultAWSRegion -Region us-west-2

$Filter = [Amazon.SimpleSystemsManagement.Model.DocumentKeyValuesFilter]::new()
$Filter.Key = 'Owner'
$Filter.Values = 'Public'

$ScriptDate = Get-Date -Format yyyy-MM-dd
$DocList = Get-SSMDocumentList -Filter $Filter

foreach ($Document in $DocList) {
  $CurrentDocument = Get-SSMDocument -Name $Document.Name -DocumentVersion $Document.DocumentVersion
  $FileName = '{0}/{1}-{2}-{3}.json' -f $ScriptDate, $Document.Owner, $CurrentDocument.Name, $Document.DocumentVersion
  $CurrentDocument | ConvertTo-Json -Depth 10 | Set-Content -Path $FileName
}
