# PR Changes Directory

This directory contains the modified files for each PR branch. Use these files to create the PR branches as described in `.github/PR_SETUP.md`.

## Structure

```
pr-changes/
├── pr1/              # PR #1: Incremental Model Filter Change
│   └── orders.sql    # Modified orders model
├── pr2/              # PR #2: Model Rename with Breaking Change
│   └── staging_orders.sql  # Renamed model (was stg_orders.sql)
└── pr3/              # PR #3: Timestamp Field Logic Change
    └── stg_orders.sql  # Modified with timezone conversion
```

## Usage

1. **For PR #1**: Copy `pr1/orders.sql` to `models/marts/orders.sql`
2. **For PR #2**: 
   - Rename `models/staging/stg_orders.sql` to `models/staging/staging_orders.sql`
   - Copy `pr2/staging_orders.sql` content to the new file
   - **DO NOT** update `models/marts/orders.sql` (intentional breaking change)
3. **For PR #3**: Copy `pr3/stg_orders.sql` to `models/staging/stg_orders.sql`

See `.github/PR_SETUP.md` for detailed branch creation instructions.

