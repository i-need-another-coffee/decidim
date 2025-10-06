# Async Remote Dispatch Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Decidim Repository (Source)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  1. Developer opens/updates PR                                       │
│     ↓                                                                │
│  2. async_remote_dispatch.yml triggers                              │
│     ↓                                                                │
│  3. Check if secrets configured ────→ [No] ──→ Skip (no error)     │
│     ↓ [Yes]                                                         │
│  4. Matrix: Check all 28 modules in parallel                        │
│     │                                                                │
│     ├─→ decidim-accountability ──→ [Modified?] ──→ [Yes] ─┐        │
│     ├─→ decidim-admin         ──→ [Modified?] ──→ [No]    │        │
│     ├─→ decidim-pages         ──→ [Modified?] ──→ [Yes] ─┐│        │
│     ├─→ ...                                                ││        │
│     └─→ decidim-verifications                              ││        │
│                                                             ││        │
│  5. For each modified module:                              ││        │
│     ├─→ Read .node-version      (22.14.0)                 ││        │
│     ├─→ Read .ruby-version      (3.3.4)                   ││        │
│     └─→ Read .decidim-version   (0.32.0.dev)              ││        │
│                                                             ││        │
│  6. Dispatch event to remote repository                    ││        │
│     with payload:                                          ││        │
│     - pr_number, pr_url, pr_sha                           ││        │
│     - node_version, ruby_version, decidim_version         ││        │
│     - module_name                                          ││        │
│                                                             ││        │
└─────────────────────────────────────────────────────────────┼┼────────┘
                                                              ││
                            🔥 ASYNC DISPATCH 🔥              ││
                            (non-blocking)                    ││
                                                              ││
┌─────────────────────────────────────────────────────────────┼┼────────┐
│                    Target Repository                        ││        │
├─────────────────────────────────────────────────────────────┼┼────────┤
│                                                             ││        │
│  1. Receive repository_dispatch event ←─────────────────────┘│        │
│                                                              │        │
│  2. decidim_module_tests.yml triggers                        │        │
│     for decidim-accountability                               │        │
│                                                              │        │
│  3. decidim_module_tests.yml triggers ←──────────────────────┘        │
│     for decidim-pages                                                 │
│                                                                        │
│  For each triggered workflow:                                         │
│     ↓                                                                 │
│  4. Checkout source repo at pr_head_sha                              │
│     ↓                                                                 │
│  5. Setup Ruby (version from payload: 3.3.4)                         │
│     ↓                                                                 │
│  6. Setup Node (version from payload: 22.14.0)                       │
│     ↓                                                                 │
│  7. Run custom tests in module_name directory                        │
│     ↓                                                                 │
│  8. Tests result:                                                     │
│     ├─→ [PASS] ─→ Post success comment to PR (optional)             │
│     └─→ [FAIL] ─→ Post failure comment to PR with logs              │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ↓
┌────────────────────────────────────────────────────────────────────────┐
│                    Back to Decidim PR                                   │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  💬 Comment posted:                                                    │
│     ┌──────────────────────────────────────────────────────────┐      │
│     │ ❌ Remote Tests Failed                                    │      │
│     │                                                           │      │
│     │ The remote tests for module `decidim-pages` failed.      │      │
│     │                                                           │      │
│     │ Details:                                                  │      │
│     │ - Workflow Run: [View logs](...)                         │      │
│     │ - Module: decidim-pages                                  │      │
│     │ - Node Version: 22.14.0                                  │      │
│     │ - Ruby Version: 3.3.4                                    │      │
│     └──────────────────────────────────────────────────────────┘      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Key Benefits

1. **Non-blocking**: PR workflow completes immediately, remote tests run async
2. **Parallel**: All 28 modules checked simultaneously
3. **Smart**: Only dispatches for actually modified modules
4. **Safe**: No errors if secrets aren't configured
5. **Informative**: PR gets comments with test results
6. **Flexible**: Easy to customize test commands
7. **Version-aware**: Uses correct Node/Ruby/Decidim versions

## Files Structure

```
.github/workflows/
├── async_remote_dispatch.yml       (Main workflow - monitors all modules)
├── dispatch_module_changes.yml     (Reusable workflow - single module)
├── ASYNC_REMOTE_DISPATCH.md        (Complete documentation)
├── EXAMPLE_TARGET_WORKFLOW.md      (Ready-to-use target workflow)
├── QUICK_START.md                  (5-minute setup guide)
└── README.md                       (Updated with async info)
```

## Configuration

### Source Repository (Decidim):
```yaml
Secrets:
  REMOTE_DISPATCH_TOKEN: ghp_xxx...    # Token with repo scope
  REMOTE_REPOSITORY: owner/repo        # Target repository
```

### Target Repository:
```yaml
Secrets:
  SOURCE_REPO_TOKEN: ghp_yyy...        # Token to comment on PRs

Workflow:
  .github/workflows/decidim_module_tests.yml
```

## Usage

1. Configure secrets (both repositories)
2. Add workflow to target repository
3. Open PR in Decidim that modifies a module
4. Watch the magic happen! ✨
