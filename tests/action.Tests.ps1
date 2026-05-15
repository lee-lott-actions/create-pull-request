Describe "Create-Pull-Request" {
  BeforeAll {
    $script:Title     = "Test PR"
    $script:Head      = "feature/test"
    $script:Base      = "main"
    $script:Body      = "This is a test pull request"
    $script:OrgName   = "my-org"
    $script:RepoName  = "my-repo"
    $script:Token     = "dummy-token"
    $script:ApiUrl    = "http://127.0.0.1:3000"
    . "$PSScriptRoot/../action.ps1"
  }
    
  BeforeEach {
    $env:GITHUB_OUTPUT = New-TemporaryFile
    $env:MOCK_API = $script:MockApiUrl
  }
  
  AfterEach {
    if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
    Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
  }

  Context "Success Cases" {
    It "unit: Create-Pull-Request succeeds with HTTP 201" {
      Mock Invoke-WebRequest {
          [PSCustomObject]@{
              StatusCode = 201
              Content = '{"html_url": "' + "$ApiUrl/$OrgName/$RepoName/pull/123" + '", "number": 123 }'
          }
      }

      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token
  
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "pr_url=$ApiUrl/$OrgName/$RepoName/pull/123"
      $output | Should -Contain "pr_number=123"
      $output | Should -Contain "result=success"
    }
  }
  
  Context "HTTP Failure Cases" {
    It "unit: Create-Pull-Request fails with HTTP 422" {
      Mock Invoke-WebRequest {
        [PSCustomObject]@{
          StatusCode = 422
          Content = '{"message": "Validation Failed."}'
        }
      }
  
      Create-Pull-Request `
          -Title $Title `
          -Head $Head `
          -Base $Base `
          -Body $Body `
          -OrgName $OrgName `
          -RepoName $RepoName `
          -Token $Token

      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Should -Contain "error-message=Error: Pull request creation failed. Status code: 422"
    }
  }
  
  Context "Parameter Validation Failure Cases" {
    It "unit: Create-Pull-Request fails with empty Title" {
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
      
    It "unit: Create-Pull-Request fails with empty Head" {
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
      
    It "unit: Create-Pull-Request fails with Base" {
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
      
    It "unit: Create-Pull-Request fails with Body" {
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
      
    It "unit: Create-Pull-Request fails with OrgName" {
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
      
    It "unit: Create-Pull-Request fails with RepoName" {
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
      
    It "unit: Create-Pull-Request fails with Token" {
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

  Context "Exception Failure Cases" {
    It "unit: Create-Pull-Request fails with exception" {
      Mock Invoke-WebRequest { throw "API Error" }
      
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
      
      $output = Get-Content $env:GITHUB_OUTPUT
      $output | Should -Contain "result=failure"
      $output | Where-Object { $_ -match "^error-message=Error: Pull request creation threw an exception and failed. Exception:" } |
			  Should -Not -BeNullOrEmpty
    }  
  }
}
