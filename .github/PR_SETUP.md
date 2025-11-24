# Setting Up PR Branches

This guide explains how to create the three training PR branches from the main branch.

## Prerequisites

- Git repository initialized
- Main branch with all base files committed

## Creating PR Branches

### PR #1: Incremental Model Filter Change

```bash
# Create and switch to PR branch
git checkout -b pr1-incremental-filter

# Make the changes (or use the files in pr-changes/pr1/)
# See pr-changes/pr1/ for the modified files

# Commit changes
git add .
git commit -m "Convert orders to incremental model with expanded status filter"
```

**Files to modify**:
- `models/marts/orders.sql` - Add incremental config and filter

### PR #2: Model Rename with Breaking Change

```bash
# Create and switch to PR branch
git checkout main
git checkout -b pr2-model-rename

# Rename the model file
git mv models/staging/stg_orders.sql models/staging/staging_orders.sql

# Update the model name inside the file
# (See pr-changes/pr2/staging_orders.sql)

# INTENTIONALLY DO NOT update models/marts/orders.sql
# This creates the breaking change for training

# Commit changes
git add .
git commit -m "Rename stg_orders to staging_orders (intentional breaking change)"
```

**Files to modify**:
- Rename: `models/staging/stg_orders.sql` → `models/staging/staging_orders.sql`
- Update model name in `staging_orders.sql`
- **DO NOT** update `models/marts/orders.sql` (this is the breaking change)

### PR #3: Timestamp Field Logic Change

```bash
# Create and switch to PR branch
git checkout main
git checkout -b pr3-timestamp-logic

# Make the changes (or use the files in pr-changes/pr3/)
# See pr-changes/pr3/ for the modified files

# Commit changes
git add .
git commit -m "Convert order_date from EST to UTC"
```

**Files to modify**:
- `models/staging/stg_orders.sql` - Add timezone conversion logic

## Quick Setup Script

Alternatively, you can use the provided files in `pr-changes/` directories:

```bash
# For each PR, copy the changed files over the originals
# Then commit as shown above
```

## Verifying PRs

After creating each branch, verify it works:

```bash
# Switch to PR branch
git checkout pr1-incremental-filter

# Build models
dbt build

# Run Recce
recce run
```

Repeat for each PR branch.

