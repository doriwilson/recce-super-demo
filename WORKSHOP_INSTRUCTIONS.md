# Workshop Instructions: Using Pre-Generated Recce State Files

This repository includes pre-generated Recce state files so you can start using Recce immediately without manual setup.

## Quick Start for Workshop Participants

### Step 1: Clone and Setup (5 minutes)

```bash
# Clone the repository
git clone <repository-url>
cd recce-super-demo

# Set up environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure dbt
cp profiles.yml.example profiles.yml

# Install dependencies
dbt deps
dbt seed
```

### Step 2: Build Database and Run Recce on Main Branch

```bash
# On main branch
git checkout main

# IMPORTANT: Build the database first (creates DuckDB with actual data)
dbt build
dbt docs generate

# Now Recce can compare actual data values, not just schema
recce server

# The pre-generated artifacts in target-base/ help, but Recce still needs
# to query the actual database for value diffs and profile diffs
```

### Step 3: Test PR #1 (Incremental Model Changes)

```bash
# Switch to PR branch
git checkout pr1-incremental-filter

# IMPORTANT: Build the database with PR changes
dbt build
dbt docs generate

# Now run Recce - it will compare actual data values
recce server

# Recce uses:
# - target-base/ (from main) as baseline artifacts
# - target/ (current PR) as comparison artifacts  
# - Queries DuckDB to compare actual row counts, values, and distributions
```

### Step 4: Test PR #2 (Breaking Change Detection)

```bash
git checkout pr2-model-rename

# Run Recce
recce server

# Recce will show the breaking change (missing stg_orders reference)
```

### Step 5: Test PR #3 (Timestamp Validation)

```bash
git checkout pr3-timestamp-logic

# Run Recce
recce server

# Recce will show timestamp value differences
```

## What's Pre-Generated?

### Main Branch
- `target-base/` - Complete base artifacts (manifest.json, catalog.json, run_results.json)
- `recce_base_state.json` - Base state file for reference

### PR Branches
- `target-base/` - Copied from main (base for comparison)
- `recce_state.json` - Pre-generated comparison state (PR vs main)

## How It Works

When you run `recce server` or `recce run` on a PR branch:

1. **Artifacts**: Recce uses `target-base/` (from main) and `target/` (current PR) for schema/metadata
2. **Data Comparison**: Recce queries the DuckDB database to compare actual data:
   - Row counts (Value Diff)
   - Column distributions (Profile Diff)  
   - Actual values (not just schema)
3. **Why build is needed**: The DuckDB file (`super_training.duckdb`) contains the actual data that Recce queries
4. **State files**: Pre-generated to speed up startup, but Recce still queries the database for comparisons

## Troubleshooting

**"Cannot load the manifest" error:**
- Ensure you're on the correct branch
- The `target-base/` directory should exist (it's committed to git)
- Run `dbt compile` to generate target/ artifacts

**"No data to compare" or empty results:**
- **You must run `dbt build` first!** This creates the DuckDB database with actual data
- Recce queries the database for value comparisons, not just the artifacts
- Check that `super_training.duckdb` exists after running `dbt build`

**"State file not found":**
- State files are committed to each branch
- If missing, regenerate: `recce run --target-base-path target-base --target-path target --output recce_state.json`

**Recce server won't start:**
- Check that port 8000 is available
- Try: `recce server --port 8001`

**Value diffs show no differences:**
- Ensure you've run `dbt build` on both main and the PR branch
- The database must contain the actual data for Recce to compare

## For Instructors

To regenerate state files after model changes:

```bash
# On main
git checkout main
dbt build
dbt docs generate
mkdir -p target-base
cp -r target/* target-base/
recce run --target-base-path target-base --target-path target --output recce_base_state.json
git add target-base/ recce_base_state.json
git commit -m "Update base artifacts"

# On each PR branch
git checkout pr1-incremental-filter
dbt build
dbt docs generate
recce run --target-base-path target-base --target-path target --output recce_state.json
git add recce_state.json
git commit -m "Update PR #1 state file"
```

---

**Workshop participants can now just `git checkout` and `recce server` - no manual setup needed!** 🎉

