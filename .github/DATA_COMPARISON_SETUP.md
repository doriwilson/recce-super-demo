# Data Comparison Setup: Why `dbt build` is Required

## Understanding Recce's Data Comparison

Recce compares **actual data values**, not just schemas. This requires the DuckDB database to be built with `dbt build`.

## Two Types of Comparisons

### 1. Schema Comparisons (from Artifacts)
- **Source**: `manifest.json`, `catalog.json` (pre-generated in `target-base/`)
- **What it compares**: Column names, data types, model structure
- **No database needed**: Just the JSON artifacts

### 2. Data Value Comparisons (from Database Queries)
- **Source**: Actual data in DuckDB database (`super_training.duckdb`)
- **What it compares**: 
  - Row counts (Value Diff)
  - Column distributions (Profile Diff)
  - Actual values (not just schema)
- **Database required**: Must run `dbt build` to create/update the database

## Why Both Are Needed

```
┌─────────────────────────────────────────┐
│  Recce Comparison Process              │
├─────────────────────────────────────────┤
│                                          │
│  1. Schema Diff (from artifacts)        │
│     - Uses manifest.json, catalog.json  │
│     - Pre-generated in target-base/     │
│     - No database query needed          │
│                                          │
│  2. Value Diff (from database)          │
│     - Queries DuckDB directly           │
│     - Compares actual row counts        │
│     - Requires dbt build                │
│                                          │
│  3. Profile Diff (from database)        │
│     - Queries DuckDB for distributions  │
│     - Compares min/max/null percentages │
│     - Requires dbt build                │
│                                          │
└─────────────────────────────────────────┘
```

## Workshop Workflow

### Step 1: Build Main Branch Database
```bash
git checkout main
dbt build
# Creates: super_training.duckdb with 25 orders (all statuses)
```

### Step 2: Build PR Branch Database  
```bash
git checkout pr1-incremental-filter
dbt build
# Updates: super_training.duckdb with 23 orders (filtered)
```

### Step 3: Run Recce
```bash
recce server
# Recce will:
# 1. Use target-base/ artifacts for schema comparison
# 2. Query DuckDB to compare:
#    - Row counts: 25 vs 23 (Value Diff)
#    - Status distribution (Profile Diff)
#    - Actual order values
```

## What's Pre-Generated vs What's Built

### Pre-Generated (Committed to Git)
- ✅ `target-base/` - Base artifacts (manifest.json, catalog.json)
- ✅ `recce_state.json` - State file metadata
- ✅ Schema information

### Must Be Built (Not in Git)
- ❌ `super_training.duckdb` - Database file (in .gitignore)
- ❌ `target/` - Current branch artifacts (in .gitignore)
- ❌ Actual data values

## Why DuckDB File is in .gitignore

The DuckDB file (`super_training.duckdb`) is:
- **Large** (~3MB)
- **Environment-specific** (paths, connections)
- **Regenerated easily** with `dbt build`
- **Contains actual data** that changes per branch

Participants build it fresh, which ensures:
- Clean state for each branch
- Correct data for comparisons
- No conflicts between branches

## Complete Workshop Flow

```bash
# 1. Setup (once)
git clone <repo>
cd recce-super-demo
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp profiles.yml.example profiles.yml
dbt deps

# 2. Main branch (baseline)
git checkout main
dbt seed
dbt build          # ← Creates DuckDB database
dbt docs generate  # ← Generates catalog.json

# 3. PR branch (comparison)
git checkout pr1-incremental-filter
dbt build          # ← Updates DuckDB with PR changes
dbt docs generate  # ← Generates PR artifacts

# 4. Run Recce
recce server       # ← Compares data using:
                   #    - target-base/ (schema from main)
                   #    - target/ (schema from PR)
                   #    - DuckDB queries (actual data values)
```

## Summary

- **Artifacts** (`target-base/`): Pre-generated, help with schema comparisons
- **Database** (`super_training.duckdb`): Must be built, required for value/profile comparisons
- **Both needed**: Recce uses artifacts for structure, database for actual data

**Key Point**: Participants must run `dbt build` to create the database that Recce queries for data comparisons!

