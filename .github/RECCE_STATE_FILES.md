# Pre-Generated Recce State Files

This repository includes pre-generated Recce state files so you can run `recce server` immediately without manual setup.

## What's Included

- **`target-base/`** (main branch): Prod schema artifacts (manifest.json, catalog.json, etc.)
- **`recce_state.json`** (each PR branch): Pre-generated state file comparing dev to prod

## How It Works

**Setup (one time):**
```bash
./scripts/setup.sh
# This builds main to prod schema - prod data is now in database
```

**On any PR branch:**
```bash
git checkout pr1-incremental-filter
dbt build --target dev       # Creates dev schema data
recce server recce_state.json # Compares dev to prod!
```

**What Recce does:**
1. Reads state file to find base artifacts (`target-base/`)
2. Compares PR branch artifacts (`target/`) to base artifacts
3. Queries **both** `prod` and `dev` schemas for actual data comparisons

## Why This Works

- **Prod schema**: Created during initial setup (main branch)
- **Dev schema**: Created when you run `dbt build --target dev` on PR branches
- **Both schemas**: Exist in the same DuckDB file (`super_training.duckdb`)
- **Recce**: Queries both for real data comparisons (row counts, values, distributions)

## What You Still Need to Do

**You must run `dbt build --target dev`** on each PR branch because:
- Recce compares actual data values between prod and dev schemas
- `dbt build --target dev` creates the dev schema data
- Prod data is already in database (from initial setup)

That's it! The pre-generated state files mean you don't need to run `recce run` manually.
