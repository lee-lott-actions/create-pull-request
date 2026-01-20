# Dummy values for required parameters
$script:Title = "Test PR"
$script:Head = "feature/test"
$script:Base = "main"
$script:Body = "This is a test pull request"
$script:OrgName = "my-org"
$script:RepoName = "my-repo"
$script:Token = "dummy-token"
$script:ApiUrl = "https://api.mytests.com"

Describe "Create-Pull-Request" {
  BeforeAll {
    . "$PSScriptRoot/../action.ps1"
  }

  BeforeEach {
    # Clean up GITHUB_OUTPUT for each test
    $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
    if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
  }
  
  AfterAll {
    if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
  }
  
  It "creates a pull request and writes outputs for a 201 status code" {
      # Arrange
      Mock Invoke-WebRequest {
          [PSCustomObject]@{
              StatusCode = 201
              Content = '{"html_url": "' + "$ApiUrl/$OrgName/$RepoName/pull/123" + '", "number": 123 }'
          }
      }

      $env:MOCK_API = $ApiUrl

      # Act
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token

      # Assert
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "pr_url=$ApiUrl/$OrgName/$RepoName/pull/123"
      $output | Should -Contain "pr_number=123"
      $output | Should -Contain "result=success"
  }

  It "writes result=failure and error-message for a non-201 status code" {
      # Arrange
      Mock Invoke-WebRequest {
          [PSCustomObject]@{
              StatusCode = 422
              Content = '{"message": "Validation Failed."}'
          }
      }

      $env:MOCK_API = $ApiUrl

      # Act
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token

      # Assert
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Pull request creation failed. Status code: 422"
  }

  It "writes result=failure and error-message on exception" {
      # Arrange
      Mock Invoke-WebRequest { throw "API Error" }
      $env:MOCK_API = $ApiUrl

      try {
        Create-Pull-Request `
            -Title $Title `
            -Head $Head `
            -Base $Base `
            -Body $Body `
            -OrgName $OrgName `
            -RepoName $RepoName `
            -Token $Token
      } catch {}

      # Assert
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Pull request creation threw an exception and failed."
  }

  It "writes result=failure for empty Title" {
      Create-Pull-Request `
          -Title "" `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }
  
  It "writes result=failure for empty Head" {
      Create-Pull-Request `
          -Title $Title `
          -Head "" `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }
  
  It "writes result=failure for empty Base" {
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base "" `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }
  
  It "writes result=failure for empty Body" {
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body "" `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }
  
  It "writes result=failure for empty OrgName" {
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName "" `
          -RepoName $RepoName `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }
  
  It "writes result=failure for empty RepoName" {
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName "" `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }
  
  It "writes result=failure for empty Token" {
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token ""
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Missing required parameters: Title, Head, Base, Body, OrgName, RepoName, and token must be provided."
  }  
}