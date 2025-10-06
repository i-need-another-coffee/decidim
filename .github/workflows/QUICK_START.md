# Quick Start: Enable Async Remote Dispatch

This guide will help you quickly enable the asynchronous remote dispatch feature to trigger workflows in another repository when PRs are opened.

## Prerequisites

1. A target repository where you want to run additional tests/checks
2. Admin access to both repositories (to add secrets)

## 5-Minute Setup

### Step 1: Create GitHub Tokens

You need two Personal Access Tokens (classic):

1. **For Decidim Repository** (to dispatch events):
   - Go to https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Name: "Remote Dispatch Token"
   - Scopes: Select `repo` (all sub-scopes)
   - Generate token and **copy it**

2. **For Target Repository** (to comment on PRs):
   - Create another token
   - Name: "Source PR Comment Token"
   - Scopes: Select `repo` (all sub-scopes)
   - Generate token and **copy it**

### Step 2: Configure Decidim Repository

1. Go to your Decidim repository settings
2. Navigate to **Settings → Secrets and variables → Actions**
3. Add these secrets:

   | Name | Value |
   |------|-------|
   | `REMOTE_DISPATCH_TOKEN` | The first token you created |
   | `REMOTE_REPOSITORY` | Your target repo (format: `owner/repo`) |

### Step 3: Configure Target Repository

1. Create `.github/workflows/` directory if it doesn't exist
2. Copy the example workflow from [EXAMPLE_TARGET_WORKFLOW.md](EXAMPLE_TARGET_WORKFLOW.md)
3. Save it as `.github/workflows/decidim_module_tests.yml`
4. Commit and push to the default branch
5. Add secret in repository settings:

   | Name | Value |
   |------|-------|
   | `SOURCE_REPO_TOKEN` | The second token you created |

### Step 4: Test It

1. Create or update a PR in the Decidim repository
2. Make a small change to any module (e.g., add a comment in `decidim-pages/`)
3. Check the Actions tab in Decidim - you should see "Remote Repository Dispatch" running
4. Check the Actions tab in your target repository - you should see "Decidim Module Tests" triggered
5. The workflow will post a comment on your PR with the results

## What Happens Next?

When you open or update a PR in Decidim:

1. ✅ The dispatch workflow checks which modules were changed
2. ✅ For each changed module, it sends an event to your target repository
3. ✅ Your target repository receives the event and runs your custom tests
4. ✅ If tests fail, a comment is posted to the original PR
5. ✅ All of this happens asynchronously without blocking the PR

## Customization

### Test Specific Modules Only

Edit `.github/workflows/async_remote_dispatch.yml` and modify the matrix:

```yaml
strategy:
  matrix:
    working-directory:
      - decidim-core
      - decidim-pages
      # Only list the modules you want to monitor
```

### Change Test Commands

Edit your target repository's workflow and modify the test step:

```yaml
- name: Run tests for module
  working-directory: ${{ github.event.client_payload.module_name }}
  run: |
    # Your custom commands here
    bundle exec rspec
    npm run test
    bundle exec rubocop
```

### Disable Success Comments

In your target repository workflow, remove or comment out the "Post success comment" step if you only want notifications for failures.

## Troubleshooting

### "Remote dispatch is not configured" message

- Make sure both `REMOTE_DISPATCH_TOKEN` and `REMOTE_REPOSITORY` secrets are set in the Decidim repository
- Check that the secret names are exactly as shown (case-sensitive)

### No workflow triggered in target repository

- Verify the workflow file is on the default branch (main/master)
- Check that `REMOTE_DISPATCH_TOKEN` has `repo` scope
- Ensure `REMOTE_REPOSITORY` is in the correct format: `owner/repo`

### Can't post comments to PR

- Verify `SOURCE_REPO_TOKEN` is set in the target repository
- Check that it has `repo` scope
- Make sure the token has write access to the Decidim repository

## Need More Help?

See the full documentation:
- [ASYNC_REMOTE_DISPATCH.md](ASYNC_REMOTE_DISPATCH.md) - Complete setup guide
- [EXAMPLE_TARGET_WORKFLOW.md](EXAMPLE_TARGET_WORKFLOW.md) - Full example workflow with explanations

## Security Notes

- Store tokens as **secrets**, never commit them
- Use separate tokens for different purposes
- Regularly rotate tokens (every 90 days recommended)
- Grant minimum necessary permissions
- Consider using fine-grained tokens or GitHub Apps for better security
