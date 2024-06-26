param(
       # Getting the control percentage as an argument
       [int]$desiredCodeCoveragePercent=80
)
Write-Host “Desired Code Coverage Percent is “ -nonewline; Write-Host $desiredCodeCoveragePercent
 
# Setting a few values
[int]$coveredBlocks=0
[int]$skippedBlocks=0
[int]$totalBlocks=0
[int]$codeCoveragePercent=0
 
# Getting a few environment variables we need
[String]$buildID=“$env:BUILD_BUILDID“
[String]$project=“$env:SYSTEM_TEAMPROJECT“
 
# Setting up basic authentication
$username="peter.williamson@equinox.co.nz"
$password="y7bcpt5zedhrem7d352fyzhayhjovjiijadzagz6tr3z5mb3d6la"
#this expires on or about 16/11/2017
 
$basicAuth= (“{0}:{1}”-f$username,$password)
$basicAuth=[System.Text.Encoding]::UTF8.GetBytes($basicAuth)
$basicAuth=[System.Convert]::ToBase64String($basicAuth)
$headers= @{Authorization=(“Basic {0}”-f$basicAuth)}
 
$url=“https://minedunz.visualstudio.com/DefaultCollection/“+$project+“/_apis/test/codeCoverage?buildId=”+$buildID+“&flags=1&api-version=2.0-preview”
Write-Host $url


$responseBuild = (Invoke-RestMethod -Uri $url -headers $headers -Method Get).value | select modules 

 
foreach($module in $responseBuild.modules)
{
	$coveredBlocks+=  $module.statistics[0].blocksCovered
	$skippedBlocks+=  $module.statistics[0].blocksNotCovered
    #Write-Host "\n"+$module.statistics[0].blocksCovered + "\t" $module.statistics[0].blocksNotCovered
}
 
$totalBlocks=$coveredBlocks+$skippedBlocks;
if ($totalBlocks-eq0)
{
	$codeCoveragePercent=0
	Write-Host $codeCoveragePercent -nonewline; Write-Host ” is the Code Coverage. Failing the build”
	exit -1 
}
 
$codeCoveragePercent=$coveredBlocks*100.0/$totalBlocks
Write-Host “Code Coverage percentage is “ -nonewline; Write-Host $codeCoveragePercent
 
if ($codeCoveragePercent-le$desiredCodeCoveragePercent)
{
	Write-Host “Failing the build as CodeCoverage limit not met”
	exit -1
}
	Write-Host “CodeCoverage limit met”