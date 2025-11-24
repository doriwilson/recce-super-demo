# Quick Start Guide

Get up and running with the Super Recce Training repository in 5 minutes.

## Setup (One Time - 3 minutes)

```bash
# Automated setup (recommended)
./scripts/setup.sh
```

**What this does:**
- Creates Python virtual environment
- Installs dbt-duckdb and recce
- Sets up profiles.yml
- Builds main branch to **prod schema** (base data for comparisons)
- Updates `target-base/` artifacts (static baseline, pre-committed)

**Expected output**: All models build successfully to prod schema in <30 seconds

**Important**: The virtual environment must be activated in each new terminal session:
```bash
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

## Running a PR (2 options)

### Option 1: Using Helper Script (Recommended)

```bash
# Activate virtual environment (if not already active)
source venv/bin/activate

# Switch to PR #1 and build automatically
./scripts/switch-pr.sh 1

# Run Recce
recce server recce_state.json
```

The script automatically:
- Discards any uncommitted changes (clean demo state)
- Switches to the PR branch
- Builds models to dev schema
- You're ready to run Recce!

### Option 2: Manual Steps

```bash
# Activate virtual environment (if not already active)
source venv/bin/activate

# 1. Switch to PR branch (discards uncommitted changes)
git checkout pr1-incremental-filter
# If you have uncommitted changes, discard them:
# git reset --hard HEAD

# 2. Build to dev schema (creates dev data for comparison)
dbt build --target dev

# 3. Run Recce (uses pre-committed artifacts!)
recce server recce_state.json
```

## All 3 PRs Work the Same Way

```bash
# Activate virtual environment first
source venv/bin/activate

# PR #1: Incremental model changes
./scripts/switch-pr.sh 1
recce server recce_state.json
# Press Ctrl+C to stop the server when done

# PR #2: Breaking change detection
./scripts/switch-pr.sh 2
recce server recce_state.json
# Press Ctrl+C to stop the server when done

# PR #3: Timestamp validation
./scripts/switch-pr.sh 3
recce server recce_state.json
# Press Ctrl+C to stop the server when done
```

## Stopping the Recce Server

**To stop Recce and switch to the next PR:**

1. **In the terminal running Recce**: Press `Ctrl+C` to stop the server
2. **If you closed the terminal**: The server may still be running. Kill it:
   ```bash
   lsof -ti:8000 | xargs kill -9
   ```
3. **Then switch to the next PR** (the script handles cleanup automatically):
   ```bash
   ./scripts/switch-pr.sh 2  # or 3
   recce server recce_state.json
   ```

## What's Pre-Generated vs What You Build

**Pre-Generated (Already Committed):**
- ✅ `target-base/` artifacts on main (prod schema metadata)
- ✅ `target/` artifacts on each PR branch (dev schema metadata)
- ✅ `recce_state.json` on each PR branch (comparison configuration)

**You Must Build:**
- 🔨 DuckDB database with **prod schema data** (done during setup)
- 🔨 DuckDB database with **dev schema data** (done when switching to PR branch)

**Why?** Recce needs:
- Artifacts (metadata) → Pre-committed, tells Recce what to compare
- Actual data → Must be built, Recce queries both schemas for real comparisons

## How It Works

1. **Setup**: Builds main branch to `prod` schema in DuckDB
2. **Switch to PR**: Builds PR branch to `dev` schema in same DuckDB file
3. **Recce**: Uses pre-committed artifacts + queries both `prod` and `dev` schemas
4. **Result**: True data comparison showing row counts, values, distributions!

## Switching Between Branches

**Important for Demo**: This is a training repo - we don't preserve changes between branches.

When switching branches:
- **Uncommitted changes are automatically discarded** (clean demo state)
- Use `./scripts/switch-pr.sh` for automatic cleanup
- Or manually: `git reset --hard HEAD` before switching

This ensures each PR branch starts in a clean state for consistent demos.

## Troubleshooting

**"command not found: dbt"**
- Activate the virtual environment: `source venv/bin/activate`
- The venv must be activated in each new terminal session

**"Profile 'super' not found"**
- Run: `cp profiles.yml.example profiles.yml`

**"No such table: jaffle_shop.orders"**
- Run `./scripts/setup.sh` again to seed the database

**"Database file is locked"**
- Close other connections or delete `super_training.duckdb` and rebuild

**"Cannot switch branch - uncommitted changes"**
- Use `./scripts/switch-pr.sh` (automatically discards changes)
- Or manually: `git reset --hard HEAD` then switch branches

**"Address already in use" (port 8000)**
- Another `recce server` is running. Stop it:
  - **If running in terminal**: Press `Ctrl+C` in that terminal
  - **If you closed the terminal**: Kill the background process:
    ```bash
    lsof -ti:8000 | xargs kill -9
    ```

**"dbt found more than one package with the name 'codegen'"**
- Clean and reinstall packages:
  ```bash
  rm -rf dbt_packages
  dbt deps
  ```

**PR #2 build fails with "depends on a node named 'stg_orders' which was not found"**
- This is **intentional** - PR #2 demonstrates breaking change detection
- The script will still generate artifacts for Recce comparison
- Recce will show the breaking change in its analysis

## Next Steps

- Review [PR descriptions](.github/pull_requests/) for what each PR demonstrates
- Use the [validation checklist](.github/validation-checklist.md) for your real projects
- See [README.md](./README.md) for full documentation

---

**Training Duration**: 45 minutes  
**Setup Time**: <5 minutes  
**Prerequisites**: Python 3.8+
