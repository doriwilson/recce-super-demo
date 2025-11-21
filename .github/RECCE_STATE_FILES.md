# Pre-Generated Recce State Files

This repository includes pre-generated Recce state files so you can run `recce server` immediately without manual setup.

## What's Pre-Generated

- **`target-base/`** (main branch): Base dbt artifacts (manifest.json, catalog.json, etc.) from the main branch
- **`recce_state.json`** (each PR branch): Pre-generated state file that tells Recce how to compare this PR to main

## How It Works

When you run `recce server recce_state.json`:
1. Recce reads the state file to find base artifacts (`target-base/`)
2. Recce compares current branch artifacts (`target/`) to base artifacts
3. Recce queries the database (created by `dbt build`) for actual data comparisons

## What You Still Need to Do

**You must run `dbt build --target dev`** on each PR branch because:
- Recce compares actual data values between prod and dev schemas
- `dbt build --target dev` creates the dev schema data that Recce queries
- Main branch is built to `prod` schema (pre-built in target-base/)
- Pre-generated state files handle the comparison setup, but data comes from `dbt build`

## Simple Workflow

```bash
# On any PR branch
git checkout pr1-incremental-filter
dbt build --target dev       # Creates dev schema data for Recce to compare
recce server recce_state.json # Compares dev data to prod data (both in database!)
```

**What this does:**
- Base (main): Uses `prod` schema data (pre-built)
- Target (PR): Uses `dev` schema data (built with `dbt build --target dev`)
- Recce queries both schemas for actual data comparisons (row counts, values, distributions)

That's it! The pre-generated state files mean you don't need to run `recce run` manually.

