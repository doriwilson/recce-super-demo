# Recce State Files Setup

This repository includes pre-generated Recce state files so workshop participants can run `recce run` immediately without manual setup.

## What's Included

### Main Branch
- `target-base/` - Base artifacts (manifest.json, catalog.json, run_results.json) from main branch
- `recce_base_state.json` - Base Recce state file for reference

### PR Branches
Each PR branch includes:
- `recce_state.json` - Pre-generated state file comparing PR branch to main
- `target/` - Generated artifacts for the PR branch

## How It Works

### For Workshop Participants

**On Main Branch:**
```bash
# Just run Recce - base artifacts are already there!
recce server
# Or
recce run
```

**On PR Branches:**
```bash
git checkout pr1-incremental-filter
recce server
# The state file is already generated, comparing to main!
```

### State Files Explained

- **`recce_base_state.json`** (main branch): Base state for reference
- **`recce_state.json`** (PR branches): Comparison state (PR vs main)
- **`target-base/`** (main branch): Base environment artifacts

## Regenerating State Files

If you need to regenerate state files (e.g., after model changes):

### Main Branch
```bash
git checkout main
dbt build
dbt docs generate
mkdir -p target-base
cp -r target/* target-base/
recce run --target-base-path target-base --target-path target --output recce_base_state.json
```

### PR Branches
```bash
git checkout pr1-incremental-filter
dbt build
dbt docs generate
recce run --target-base-path target-base --target-path target --output recce_state.json
```

## Why This Setup?

1. **No Manual Setup**: Participants don't need to generate base artifacts
2. **Consistent Comparisons**: Everyone compares against the same base
3. **Faster Start**: No waiting for `dbt docs generate` on main
4. **Workshop Ready**: Just `git checkout` and `recce server`

## File Sizes

State files are JSON and typically small (<1MB). The `target-base/` directory contains dbt artifacts and may be larger, but it's essential for comparisons.

## Troubleshooting

**"Cannot load the manifest" error:**
- Ensure `target-base/` exists on main branch
- Run `dbt docs generate` to create catalog.json

**State file outdated:**
- Regenerate using commands above
- Commit updated state files to git

---

**Note**: These state files are committed to git to make the workshop seamless. In production, you'd typically generate these in CI/CD rather than committing them.

