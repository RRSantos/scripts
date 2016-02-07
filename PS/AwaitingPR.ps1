$baseTfsUrl = "http://tfs-instance/CollectionName"
$user = "user"
$pass = "password"



$securePass = ConvertTo-SecureString -String $pass -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $securePass
$headers = @{
"Accept" = "application/json"
}

$reposUrl = "$baseTfsUrl/_apis/git/repositories?api-version=1.0"
#Getting repositories
Write-Progress -Activity "Getting repositories..." -CurrentOperation "Searching for repositories on $baseTfsUrl" -PercentComplete 50
$reposResult = Invoke-RestMethod -Method Get -Uri $reposUrl -Header $headers -Credential $credential
Write-Progress -Activity "Getting pull requests..." -CurrentOperation "Getting repositories from $baseTfsUrl" -PercentComplete 100


Write-Host "`n`nPull requests found"
Write-Host "---------------------------------------------------------"
$totalPullRequest = 0
$totalRepos = $reposResult.count
for($i=0; $i -lt $totalRepos; $i++){
	$repoName = $reposResult.value[$i].name
	$repoId = $reposResult.value[$i].id
	$precentComplete = ($i/$totalRepos)*100
	Write-Progress -Activity "Getting pull requests..." -CurrentOperation "Searching for pull requests in $repoName" -PercentComplete $precentComplete
	
	$pullRequestUrl = "$baseTfsUrl/_apis/git/repositories/$repoId/pullrequests?api-version=1.0"
	$pullRequestResult = Invoke-RestMethod -Method Get -Uri $pullRequestUrl -Header $headers -Credential $credential
	
	if ($pullRequestResult.count -gt 0){
		$totalPullRequest +=  $pullRequestResult.count
		Write-Host "`n - Repository $repoName ($($pullRequestResult.count))"
		for($j=0; $j -lt $pullRequestResult.count; $j++){
		$prId = $pullRequestResult.value[$j].pullRequestId	
		$prTargetBranch = $pullRequestResult.value[$j].targetRefName
		$prCreationDate = $pullRequestResult.value[$j].creationDate
		
			Write-Host "     - Pull request $prId `t target branch: $prTargetBranch `t created on: $prCreationDate"
		}
	}
}
$fontColor = "Green"
if ($totalPullRequest -gt 0){
	$fontColor = "Yellow"
}
Write-Host "`nTotal pull requests awaiting approval: $totalPullRequest`n" -ForegroundColor $fontColor
