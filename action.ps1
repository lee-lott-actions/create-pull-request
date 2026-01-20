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
      "X-GitHub-Api-Version" = "2022-11-28"
      "User-Agent" = "pwsh-action"
  }
  
  $body = @{
      title = $Title
      head = $Head
      base = $Base
      body = $Body
  } | ConvertTo-Json

  try {
    Write-Host "Creating Pull Request..."
    $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method POST -Body $body

    if ($response.StatusCode -eq 201) {
      $pr = $response.Content | ConvertFrom-Json
      "pr_url=$($pr.html_url)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
      "pr_number=$($pr.number)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
      "result=success" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
      Write-Host "Pull Request #$($pr.number) created."
    } else {
      "result=failure" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
      "error-message=Pull request creation failed. Status code: $($response.StatusCode)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
      Write-Host "Pull request creation failed. Status code: $($response.StatusCode)"
    }
  } catch {
    "result=failure" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    "error-message=Pull request creation threw an exception and failed." | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    Write-Error "Failed to create pull request: $_"
  }
}