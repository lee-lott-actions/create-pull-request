function Create-Pull-Request {
  param(
    [string]$Title,
    [string]$Head,
    [string]$Base,
    [string]$Body,
    [string]$OrgName,
    [string]$RepoName,    
    [string]$token
  )

  # Validate required inputs
  if ([string]::IsNullOrEmpty($Title) -or
      [string]::IsNullOrEmpty($Head) -or
      [string]::IsNullOrEmpty($Base) -or
      [string]::IsNullOrEmpty($Body) -or
      [string]::IsNullOrEmpty($OrgName) -or
      [string]::IsNullOrEmpty($RepoName) -or
      [string]::IsNullOrEmpty($token))
  {
    Write-Output "Error: Missing required parameters"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
    return
  }

  $githubApiUrl = $env:MOCK_API
  if (-not $githubApiUrl) { $githubApiUrl = "https://api.github.com" }
  $uri = "$githubApiUrl/repos/$OrgName/$RepoName/pulls"

  $headers = @{
      Authorization = "Bearer $token"
      Accept = "application/vnd.github+json"
      "Content-Type" = "application/json"
      "X-GitHub-Api-Version" = "2026-03-10"
  }
  
  $body = @{
      title = $Title
      head = $Head
      base = $Base
      body = $Body
  } | ConvertTo-Json

  try {
    Write-Host "Creating Pull Request..."
    $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method POST -Body $body -SkipHttpErrorCheck

    if ($response.StatusCode -eq 201) {
      $pr = $response.Content | ConvertFrom-Json
      Add-Content -Path $env:GITHUB_OUTPUT -Value "pr_url=$($pr.html_url)"
      Add-Content -Path $env:GITHUB_OUTPUT -Value "pr_number=$($pr.number)"
      Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
      Write-Host "Pull Request #$($pr.number) created."
    } else {
      $errorMsg = "Error: Pull request creation failed. Status code: $($response.StatusCode)"
      Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
      Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
      Write-Host $errorMsg
    }
  } catch {
    $errorMsg = "error-message=Error: Pull request creation threw an exception and failed. Exception : $($_.Exception.Message)"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
    Write-Host $errorMsg
  }
}
