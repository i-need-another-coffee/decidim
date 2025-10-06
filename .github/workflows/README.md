# Decidim GitHub Actions workflows

We use GitHub Actions as CI.

## Core CI Workflows

- `lint_code.yml`: runs the linters for Ruby, JS and ERB files.
- `ci_main.yml`: runs the tests for the main folder
- `ci_core.yml`: runs the tests for the `decidim-core` module. The remaining workflows (except noted) are based on this one.

## Async Remote Dispatch Workflows

- `async_remote_dispatch.yml`: Automatically dispatches events to a remote repository when PRs modify Decidim modules. See [ASYNC_REMOTE_DISPATCH.md](ASYNC_REMOTE_DISPATCH.md) for full documentation.
- `dispatch_module_changes.yml`: Reusable workflow for dispatching module changes to remote repositories. Can be called from individual module workflows.

These workflows enable triggering non-blocking remote GitHub Actions with context about:
- PR information (number, URL, branch)
- Version information (Node, Ruby, Decidim)
- Modified module name

For setup and usage instructions, see [ASYNC_REMOTE_DISPATCH.md](ASYNC_REMOTE_DISPATCH.md) and [EXAMPLE_TARGET_WORKFLOW.md](EXAMPLE_TARGET_WORKFLOW.md).

## Individual Module Workflows

- `ci_generators.yml`: `decidim-generators` does not need to create the test_app, so this command is removed. Screenshots uploads and chromedriver setup steps are also not needed for this module and thus removed. We also customize the gems path after running `bundle install`:

```yml
# ci_generators.yml
- run: bundle install --path vendor/bundle --jobs 4 --retry 3
  name: Install Ruby deps
- run: cp -R vendor/bundle decidim-generators
- run: bundle exec rspec
  name: RSpec
  working-directory: ${{ env.DECIDIM_MODULE }}
```

- `ci_javascript.yml`: Runs tests for the JS files. Tests must run from the project root folder. You will need to install NodeJS and the JS dependencies:

```yml
- uses: actions/setup-node@v4
  with:
    node-version: ${{ env.NODE_VERSION }}
- run: npm ci
  name: Install JS deps
- run: npm run test
  name: Test JS files
```

- Some specs are split in three workflows, so if we need to retry this particular workflow we do not need to retry all the module suite. For instance proposals:

  - `ci_proposals_system_admin.yml`: Runs the system specs for the admin section
  - `ci_proposals_system_public.yml`: Runs the system specs for the public section
  - `ci_proposals_unit_tests.yml`: Runs the unit tests

- `ci_performance_metrics_monitoring.yml`: Runs Lighthouse metrics expectations against the app to detect any performance regression. The expectations can be found in `lighthouse_budget.json`, where a time is defined for each metric:

  - [First Contentful Paint](https://web.dev/first-contentful-paint/): 2 seconds
  - [Speed Index](https://web.dev/speed-index/): 4 seconds
  - [Time to Interactive](https://web.dev/interactive/): 5 seconds
  - [Largest Contentful Paint](https://web.dev/lcp/): 2.5 seconds
