# Create Pull Request GitHub Action

This GitHub Action creates a pull request from a source branch to a target branch using the GitHub REST API.  
It is designed to be simple, composable, and independent of the local git state.

## Features

- Opens a pull request from any branch to any branch in your repository.
- Uses the GitHub REST API (no dependencies on the CLI or local git).
- Fully supports GitHub Organizations and user-owned repositories.
- Outputs the pull request URL, number, result, and error message (if any) for use in subsequent workflow steps.
- Designed for secure automation with the minimal required token permissions.

## Inputs

| Name            | Description                                         | Required | Default |
|-----------------|-----------------------------------------------------|----------|---------|
| `source-branch` | The branch you want to merge from (head)            | Yes      |         |
| `target-branch` | The branch you want to merge into (base)            | Yes      |         |
| `pr-title`      | The title for the pull request                      | Yes      |         |
| `pr-body`       | The body description for the pull request           | Yes      |         |
| `org-name`      | The name of the GitHub Organization or user         | Yes      |         |
| `repo-name`     | The name of the repository                          | Yes      |         |
| `token`         | GitHub token with access to pull requests           | Yes      |         |

## Outputs

| Name           | Description                                   |
|----------------|-----------------------------------------------|
| `pr-url`       | The URL of the created pull request           |
| `pr-number`    | The number of the created pull request        |
| `result`       | `"success"` or `"failure"` for the operation  |
| `error-message`| Error message if the pull request failed      |

## Usage

Create a workflow file in your repository (e.g., `.github/workflows/create-pr.yml`).  
**Ensure you pass all required inputs and use a valid token with PR write access.**

### Example Workflow

```yaml
name: Create Pull Request from Main to Development
on:
  workflow_dispatch:

jobs:
  create-pull-request:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v6

      - name: Create Pull Request via API
        id: create-pr
        uses: lee-lott-actions/create-pull-request@v1
        with:
          source-branch: 'main'
          target-branch: 'development'
          pr-title: 'Sync main to development'
          pr-body: 'Automated PR to keep development up-to-date with main.'
          org-name: ${{ github.repository_owner }}
          repo-name: ${{ github.event.repository.name }}
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Output PR Info
        run: |
          echo "Pull Request URL: ${{ steps.create-pr.outputs.pr-url }}"
          echo "Pull Request Number: ${{ steps.create-pr.outputs.pr-number }}"
          echo "Result: ${{ steps.create-pr.outputs.result }}"
          echo "Error Message: ${{ steps.create-pr.outputs.error-message }}"
```
