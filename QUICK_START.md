# Quick Start Guide

Get up and running in 5 minutes. This repository has pre-generated artifacts, so you just need to build the data and run Recce.

## Setup (One Time - 3 minutes)

```bash
# 1. Set up environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 2. Configure dbt
cp profiles.yml.example profiles.yml

# 3. Install packages and load data
dbt deps
dbt seed
```

## Running the Training PRs

### PR #1: Incremental Model Changes

```bash
# Switch to PR branch
git checkout pr1-incremental-filter

# Build models (creates data for Recce to compare)
dbt build

# Run Recce to see the changes
recce server
```

**What you'll see**: Recce shows row count differences (25 → 23 orders) and status distribution changes.

### PR #2: Breaking Change Detection

```bash
git checkout pr2-model-rename

# Try to build (will fail - that's the point!)
dbt build

# Run Recce to see it catch the breaking change
recce server
```

**What you'll see**: Recce detects the missing `stg_orders` reference.

### PR #3: Timestamp Validation

```bash
git checkout pr3-timestamp-logic

# Build models
dbt build

# Run Recce
recce server
```

**What you'll see**: Recce shows timestamp value differences (dates shifted by 5 hours).

## Why Run `dbt build`?

**Recce compares actual data values**, not just schemas. Running `dbt build`:
- Creates the data that Recce compares
- Updates models with your PR changes
- Generates artifacts Recce uses for comparisons

**Pre-generated artifacts** (`target-base/`) help with schema comparisons, but you still need `dbt build` for data value comparisons.

## Troubleshooting

**"Profile 'super' not found"**
- Run: `cp profiles.yml.example profiles.yml`

**"No such table: jaffle_shop.orders"**
- Run: `dbt seed` to load seed data

**"Cannot load the manifest"**
- Run: `dbt build` first to generate artifacts

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

