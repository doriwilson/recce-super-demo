# Quick Start Guide

Get up and running with the Super Recce Training repository in 5 minutes.

```bash
# This does steps 1-3 automatically or you can do manually below
./scripts/setup.sh  
```

## Step 1: Initial Setup (2 minutes)

```bash
# Clone or navigate to the repository
cd super-recce-training

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
# Or: pip install dbt-duckdb recce
```

## Step 2: Configure dbt (1 minute)

```bash
# Copy profiles template
cp profiles.yml.example profiles.yml

# Edit profiles.yml if needed (usually fine as-is)
# The default uses local DuckDB - no warehouse needed!
```

## Step 3: Build Base Project (1 minute)

```bash
# Install dbt packages
dbt deps

# Load seed data
dbt seed

# Build main branch to prod schema (base data for comparisons)
dbt build --target prod
```

**Expected output**: All models build successfully to prod schema in <30 seconds

**Why prod?** This creates the base/production data that Recce compares against. PR branches will build to `dev` schema.

## Step 4: Create PR Branches (1 minute)

```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit: base repository"

# Create PR branches (see .github/PR_SETUP.md for details)
```

## Step 5: Test a PR (1 minute)

```bash
# Switch to PR #1
git checkout pr1-incremental-filter

# Build models to dev schema (creates dev data for Recce to compare)
dbt build --target dev

# Run Recce - compares dev data to prod data!
recce server recce_state.json
```

**What happens**: Recce compares your PR branch (dev schema) to main (prod schema) using actual data from both environments. The pre-generated state file handles the setup automatically!

## Troubleshooting

**"Database file is locked"**
- Close any other connections to the DuckDB file
- Delete `super_training.duckdb` and rebuild

**"Profile 'super' not found"**
- Ensure `profiles.yml` exists in `~/.dbt/` or project root
- Check that it matches `profiles.yml.example`

**"No such table: jaffle_shop.orders"**
- Run `dbt seed` first to load seed data

## Next Steps

1. Review the [README.md](./README.md) for full documentation
2. Work through each PR:
   - [PR #1](./.github/pull_requests/pr1-incremental-filter.md): Incremental model changes
   - [PR #2](./.github/pull_requests/pr2-model-rename.md): Breaking change detection
   - [PR #3](./.github/pull_requests/pr3-timestamp-logic.md): Timestamp validation
3. Use the [validation checklist](./.github/validation-checklist.md) for your real projects

## Help

- Full documentation: [README.md](./README.md)
- PR setup guide: [.github/PR_SETUP.md](./.github/PR_SETUP.md)
- Validation checklist: [.github/validation-checklist.md](./.github/validation-checklist.md)

---

**Training Duration**: 45 minutes  
**Setup Time**: <5 minutes  
**Prerequisites**: Python 3.8+, Recce Cloud access
