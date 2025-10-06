# Asynchronous Remote GitHub Workflows

This document explains how to set up and use asynchronous GitHub workflows that dispatch events to remote repositories when PRs are opened in the Decidim repository.

## Overview

The async remote dispatch system allows you to trigger non-blocking GitHub Actions in external repositories whenever a PR is opened or updated in this repository. The system automatically:

- Detects which Decidim modules have been modified
- Reads version information from configuration files
- Dispatches events to a remote repository with all necessary context

## Workflow Files

### 1. `async_remote_dispatch.yml`

This is a standalone workflow that monitors all Decidim modules and dispatches to a remote repository when changes are detected. It runs a matrix job for all modules simultaneously.

**Configuration required:**
- `REMOTE_DISPATCH_TOKEN`: GitHub personal access token with `repo` scope for the target repository
- `REMOTE_REPOSITORY`: Target repository in format `owner/repo`

### 2. `dispatch_module_changes.yml`

This is a reusable workflow that can be called from other workflows to dispatch changes for a specific module.

## Setup Instructions

### In This Repository (Source)

1. **Add Repository Secrets:**
   Navigate to Settings → Secrets and Variables → Actions and add:
   
   - `REMOTE_DISPATCH_TOKEN`: A GitHub Personal Access Token with `repo` scope
     - Go to https://github.com/settings/tokens
     - Create a token with `repo` scope
     - Add it as a repository secret
   
   - `REMOTE_REPOSITORY`: The target repository (e.g., `myorg/my-decidim-tests`)
     - Add this as a repository variable or secret

2. **Enable the Workflow:**
   The `async_remote_dispatch.yml` workflow is ready to use once the secrets are configured.

### In the Target Repository (Destination)

Create a workflow file that listens for the dispatched events. Here's a complete example:

```yaml
name: "Decidim Module Tests"

on:
  repository_dispatch:
    types: [decidim-module-changed]

permissions:
  contents: read
  pull-requests: write  # Needed to post comments back to the source PR

jobs:
  run-tests:
    name: Test Decidim Module
    runs-on: ubuntu-22.04
    timeout-minutes: 60
    
    steps:
      - name: Print received payload
        run: |
          echo "PR Number: ${{ github.event.client_payload.pr_number }}"
          echo "PR URL: ${{ github.event.client_payload.pr_url }}"
          echo "Module: ${{ github.event.client_payload.module_name }}"
          echo "Node Version: ${{ github.event.client_payload.node_version }}"
          echo "Ruby Version: ${{ github.event.client_payload.ruby_version }}"
          echo "Decidim Version: ${{ github.event.client_payload.decidim_version }}"
          echo "Repository: ${{ github.event.client_payload.repository }}"
          echo "Head SHA: ${{ github.event.client_payload.pr_head_sha }}"

      - name: Checkout source repository
        uses: actions/checkout@v4
        with:
          repository: ${{ github.event.client_payload.repository }}
          ref: ${{ github.event.client_payload.pr_head_sha }}
          fetch-depth: 1

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ github.event.client_payload.ruby_version }}
          bundler-cache: true

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ github.event.client_payload.node_version }}
          cache: 'npm'

      - name: Install dependencies
        run: |
          npm ci
          bundle install

      - name: Run tests for module
        id: tests
        working-directory: ${{ github.event.client_payload.module_name }}
        run: |
          # Your custom test commands here
          bundle exec rake test_app
          bundle exec rspec
        continue-on-error: true

      - name: Post failure comment to PR
        if: steps.tests.outcome == 'failure'
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.SOURCE_REPO_TOKEN }}
          script: |
            const { owner, repo } = context.repo;
            const sourceRepo = '${{ github.event.client_payload.repository }}'.split('/');
            
            await github.rest.issues.createComment({
              owner: sourceRepo[0],
              repo: sourceRepo[1],
              issue_number: ${{ github.event.client_payload.pr_number }},
              body: `## ❌ Remote Tests Failed\n\nThe remote tests for module \`${{ github.event.client_payload.module_name }}\` have failed.\n\n**Details:**\n- Workflow Run: ${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}\n- Module: ${{ github.event.client_payload.module_name }}\n- Node Version: ${{ github.event.client_payload.node_version }}\n- Ruby Version: ${{ github.event.client_payload.ruby_version }}\n- Decidim Version: ${{ github.event.client_payload.decidim_version }}\n\nPlease check the workflow run for more details.`
            });

      - name: Post success comment to PR (optional)
        if: steps.tests.outcome == 'success'
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.SOURCE_REPO_TOKEN }}
          script: |
            const { owner, repo } = context.repo;
            const sourceRepo = '${{ github.event.client_payload.repository }}'.split('/');
            
            await github.rest.issues.createComment({
              owner: sourceRepo[0],
              repo: sourceRepo[1],
              issue_number: ${{ github.event.client_payload.pr_number }},
              body: `## ✅ Remote Tests Passed\n\nThe remote tests for module \`${{ github.event.client_payload.module_name }}\` have passed successfully.\n\n**Details:**\n- Workflow Run: ${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}\n- Module: ${{ github.event.client_payload.module_name }}`
            });
```

**Important:** In the target repository, you'll need to add a secret:
- `SOURCE_REPO_TOKEN`: A GitHub Personal Access Token with permissions to comment on PRs in the source repository

## Payload Structure

The dispatched event includes the following data in `client_payload`:

| Field | Type | Description |
|-------|------|-------------|
| `pr_number` | number | The pull request number |
| `pr_id` | number | The internal pull request ID |
| `pr_url` | string | The URL to the pull request |
| `pr_title` | string | The title of the pull request |
| `pr_head_ref` | string | The name of the PR branch |
| `pr_head_sha` | string | The commit SHA of the PR head |
| `pr_base_ref` | string | The base branch name |
| `repository` | string | The source repository (format: owner/repo) |
| `node_version` | string | Node.js version from `.node-version` |
| `ruby_version` | string | Ruby version from `.ruby-version` |
| `decidim_version` | string | Decidim version from `.decidim-version` |
| `module_name` | string | The name of the modified module (e.g., `decidim-pages`) |
| `triggered_by` | string | The GitHub username who triggered the workflow |

## Using the Reusable Workflow

You can also call the `dispatch_module_changes.yml` workflow from individual module CI workflows. Example:

```yaml
name: "[CI] Pages"
on:
  pull_request:
    branches-ignore:
      - "chore/l10n*"

jobs:
  tests:
    name: Tests
    uses: ./.github/workflows/test_app.yml
    secrets: inherit
    with:
      working-directory: "decidim-pages"
      test_command: bundle exec rspec

  dispatch:
    name: Dispatch to Remote
    uses: ./.github/workflows/dispatch_module_changes.yml
    secrets: inherit
    with:
      working-directory: "decidim-pages"
      remote-repository: ${{ vars.REMOTE_REPOSITORY }}
```

## Customization

### Filtering Modules

If you want to dispatch only for specific modules, edit the matrix in `async_remote_dispatch.yml`:

```yaml
strategy:
  matrix:
    working-directory:
      - decidim-pages
      - decidim-core
      # Add only the modules you want to monitor
```

### Custom Event Types

You can create different event types for different purposes. In the dispatch step, change:

```yaml
event-type: decidim-module-changed
```

To:

```yaml
event-type: decidim-security-scan  # or any other event type
```

Then in your target repository, listen for that specific event:

```yaml
on:
  repository_dispatch:
    types: [decidim-security-scan]
```

## Troubleshooting

### Workflow doesn't trigger

1. Verify `REMOTE_DISPATCH_TOKEN` has `repo` scope
2. Check that `REMOTE_REPOSITORY` is in the correct format: `owner/repo`
3. Ensure the token has access to the target repository

### No comments on PR

1. Verify `SOURCE_REPO_TOKEN` in the target repository has `repo` scope
2. Check workflow logs in the target repository for API errors
3. Ensure the token has write access to the source repository

### Module changes not detected

1. The workflow checks for file changes using `git diff`
2. Ensure your PR actually modifies files in the module directory
3. Check the workflow logs for the "Check if module was modified" step

## Security Considerations

- The `REMOTE_DISPATCH_TOKEN` should be stored as a repository secret, not hardcoded
- Use separate tokens for different purposes (dispatch vs commenting)
- Regularly rotate tokens
- Grant minimum necessary permissions (use fine-grained tokens when possible)
- Consider using GitHub Apps instead of PATs for enhanced security

## Performance Notes

- The `async_remote_dispatch.yml` workflow runs a matrix job for all modules, but only dispatches for modified ones
- Each module check runs in parallel, so the workflow completes quickly
- The actual tests run asynchronously in the remote repository, not blocking the PR
- Failed jobs don't prevent the workflow from completing (fail-fast: false)
