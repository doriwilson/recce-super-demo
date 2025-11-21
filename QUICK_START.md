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
- Generates artifacts

**Expected output**: All models build successfully to prod schema in <30 seconds

## Running a PR (1 minute)

```bash
# 1. Switch to any PR branch
git checkout pr1-incremental-filter

# 2. Build to dev schema (creates dev data)
dbt build --target dev

# 3. Run Recce (compares dev to prod!)
recce server recce_state.json
```

**What happens:**
- Recce compares your PR branch (dev schema) to main (prod schema)
- Shows actual data differences: row counts, values, distributions
- Pre-generated state files handle everything automatically!

## All 3 PRs Work the Same Way

```bash
# PR #1: Incremental model changes
git checkout pr1-incremental-filter
dbt build --target dev
recce server recce_state.json

# PR #2: Breaking change detection
git checkout pr2-model-rename
dbt build --target dev
recce server recce_state.json

# PR #3: Timestamp validation
git checkout pr3-timestamp-logic
dbt build --target dev
recce server recce_state.json
```

## Why `--target dev`?

- **Main branch**: Built to `prod` schema (during setup)
- **PR branches**: Build to `dev` schema
- **Recce**: Queries both schemas for actual data comparison
- **Result**: True prod vs dev data comparison!

## Troubleshooting

**"Profile 'super' not found"**
- Run: `cp profiles.yml.example profiles.yml`

**"No such table: jaffle_shop.orders"**
- Run: `dbt seed` first

**"Database file is locked"**
- Close other connections or delete `super_training.duckdb` and rebuild

## Next Steps

- Review [PR descriptions](.github/pull_requests/) for what each PR demonstrates
- Use the [validation checklist](.github/validation-checklist.md) for your real projects
- See [README.md](./README.md) for full documentation

---

**Training Duration**: 45 minutes  
**Setup Time**: <5 minutes  
**Prerequisites**: Python 3.8+
