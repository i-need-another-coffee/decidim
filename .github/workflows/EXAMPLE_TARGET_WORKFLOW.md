# Example Target Repository Workflow

This is a complete example workflow that should be added to your target repository to receive and process dispatched events from the Decidim repository.

Save this file as `.github/workflows/decidim_module_tests.yml` in your target repository.

```yaml
name: "Decidim Module Tests"

on:
  repository_dispatch:
    types: [decidim-module-changed]

permissions:
  contents: read
  pull-requests: write

jobs:
  run-tests:
    name: Test Module ${{ github.event.client_payload.module_name }}
    runs-on: ubuntu-22.04
    timeout-minutes: 60
    
    steps:
      - name: Print received payload
        run: |
          echo "=== Decidim Module Test Triggered ==="
          echo "PR Number: ${{ github.event.client_payload.pr_number }}"
          echo "PR URL: ${{ github.event.client_payload.pr_url }}"
          echo "Module: ${{ github.event.client_payload.module_name }}"
          echo "Node Version: ${{ github.event.client_payload.node_version }}"
          echo "Ruby Version: ${{ github.event.client_payload.ruby_version }}"
          echo "Decidim Version: ${{ github.event.client_payload.decidim_version }}"
          echo "Repository: ${{ github.event.client_payload.repository }}"
          echo "Head SHA: ${{ github.event.client_payload.pr_head_sha }}"
          echo "Triggered by: ${{ github.event.client_payload.triggered_by }}"

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

      - name: Setup test environment
        run: |
          # Add any environment setup needed for your tests
          sudo apt-get update
          sudo apt-get install -y postgresql-client

      - name: Run tests for module
        id: tests
        working-directory: ${{ github.event.client_payload.module_name }}
        run: |
          # Customize these commands based on your testing needs
          echo "Running tests for ${{ github.event.client_payload.module_name }}"
          
          # Example test commands:
          bundle exec rake test_app
          bundle exec rspec
          
          # Or use your custom test commands
        continue-on-error: true

      - name: Post failure comment to PR
        if: steps.tests.outcome == 'failure'
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.SOURCE_REPO_TOKEN }}
          script: |
            const sourceRepo = '${{ github.event.client_payload.repository }}'.split('/');
            const runUrl = `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`;
            
            const body = `## ❌ Remote Tests Failed

The remote tests for module \`${{ github.event.client_payload.module_name }}\` have failed.

**Details:**
- **Workflow Run:** [View logs](${runUrl})
- **Module:** \`${{ github.event.client_payload.module_name }}\`
- **Node Version:** ${{ github.event.client_payload.node_version }}
- **Ruby Version:** ${{ github.event.client_payload.ruby_version }}
- **Decidim Version:** ${{ github.event.client_payload.decidim_version }}
- **Commit:** ${{ github.event.client_payload.pr_head_sha }}

Please check the workflow run for more details.`;

            await github.rest.issues.createComment({
              owner: sourceRepo[0],
              repo: sourceRepo[1],
              issue_number: ${{ github.event.client_payload.pr_number }},
              body: body
            });

      - name: Post success comment to PR (optional)
        if: steps.tests.outcome == 'success'
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.SOURCE_REPO_TOKEN }}
          script: |
            const sourceRepo = '${{ github.event.client_payload.repository }}'.split('/');
            const runUrl = `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`;
            
            const body = `## ✅ Remote Tests Passed

The remote tests for module \`${{ github.event.client_payload.module_name }}\` have passed successfully.

**Details:**
- **Workflow Run:** [View logs](${runUrl})
- **Module:** \`${{ github.event.client_payload.module_name }}\`
- **Commit:** ${{ github.event.client_payload.pr_head_sha }}`;

            await github.rest.issues.createComment({
              owner: sourceRepo[0],
              repo: sourceRepo[1],
              issue_number: ${{ github.event.client_payload.pr_number }},
              body: body
            });
```

## Setup Instructions

### 1. Add this workflow to your target repository

1. Create the directory `.github/workflows/` in your target repository if it doesn't exist
2. Save the above workflow as `decidim_module_tests.yml`
3. Commit and push the file

### 2. Configure Secrets

In your target repository, add the following secret:

- **Secret Name:** `SOURCE_REPO_TOKEN`
- **Value:** A GitHub Personal Access Token with `repo` scope
- **Purpose:** Allows the workflow to post comments on PRs in the source Decidim repository

To create the token:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Decidim PR Comment Token")
4. Select the `repo` scope
5. Generate and copy the token
6. Add it to your repository secrets

### 3. Configure the Source Repository

In the source Decidim repository, add:

- **Secret Name:** `REMOTE_DISPATCH_TOKEN`
- **Value:** A GitHub Personal Access Token with `repo` scope for the target repository
- **Purpose:** Allows dispatching events to the target repository

- **Variable Name:** `REMOTE_REPOSITORY`  
- **Value:** Your target repository in format `owner/repo` (e.g., `myorg/decidim-tests`)
- **Purpose:** Specifies where to dispatch events

### 4. Customize the Test Commands

Modify the "Run tests for module" step to include your specific test commands:

```yaml
- name: Run tests for module
  id: tests
  working-directory: ${{ github.event.client_payload.module_name }}
  run: |
    # Your custom test commands
    bundle exec rake test_app
    bundle exec rspec
    
    # Or any other commands you need
    bundle exec rubocop
    npm run test
  continue-on-error: true
```

## How It Works

1. When a PR is opened/updated in the Decidim repository
2. The `async_remote_dispatch.yml` workflow detects which modules changed
3. For each changed module, it dispatches an event to your target repository
4. This workflow receives the event and runs your custom tests
5. If tests fail, it posts a comment back to the original PR

## Testing the Setup

To test if everything is working:

1. Make a small change to any Decidim module in a PR
2. Check the Actions tab in the Decidim repository - you should see the dispatch workflow running
3. Check the Actions tab in your target repository - you should see this workflow triggered
4. Check the PR in Decidim - you should see a comment posted by the workflow

## Troubleshooting

### Workflow doesn't trigger
- Verify `SOURCE_REPO_TOKEN` exists and has correct permissions
- Check that the workflow file is on the default branch (usually `main` or `master`)
- Look for errors in the Decidim repository's dispatch workflow

### Can't post comments
- Verify `SOURCE_REPO_TOKEN` has `repo` scope
- Check the token hasn't expired
- Ensure the token has write access to the source repository

### Tests fail unexpectedly
- Check that all dependencies are installed correctly
- Verify the Ruby and Node versions match the source repository
- Look at the full workflow logs for detailed error messages
