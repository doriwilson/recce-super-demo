# Pre-Generated Recce State Files

This repository includes pre-generated Recce artifacts to speed up the workshop.

## What's Pre-Generated

- **`target-base/`** (main branch): Base artifacts for schema comparisons
- **`recce_state.json`** (PR branches): State file metadata

## What You Still Need to Do

**You must run `dbt build`** on each branch because:
- Recce compares actual data values (row counts, distributions)
- `dbt build` creates the data that Recce queries
- Pre-generated artifacts help with schema, but data comes from `dbt build`

## Simple Workflow

```bash
# On any PR branch
git checkout pr1-incremental-filter
dbt build          # Creates data for Recce to compare
recce server       # Compares PR to main automatically
```

That's it! The pre-generated artifacts mean you don't need to manually set up baseline comparisons.

