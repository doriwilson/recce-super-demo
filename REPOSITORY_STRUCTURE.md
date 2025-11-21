# Repository Structure

Complete file structure for the Super Recce Training repository.

```
super-recce-training/
│
├── .github/
│   ├── pull_requests/
│   │   ├── pr1-incremental-filter.md      # PR #1 documentation
│   │   ├── pr2-model-rename.md             # PR #2 documentation
│   │   └── pr3-timestamp-logic.md          # PR #3 documentation
│   ├── workflows/
│   │   └── recce-ci.yml                    # Optional: GitHub Actions CI demo
│   ├── PR_SETUP.md                         # Guide to create PR branches
│   └── validation-checklist.md             # Reusable validation template
│
├── models/
│   ├── staging/
│   │   ├── stg_customers.sql               # Customer staging model
│   │   ├── stg_orders.sql                  # Order staging (PR #3 modifies this)
│   │   └── stg_payments.sql                # Payment staging model
│   ├── intermediate/
│   │   └── int_order_payments.sql          # Payment aggregations
│   ├── marts/
│   │   ├── orders.sql                      # Final orders model (PR #1 modifies this)
│   │   └── customer_orders.sql              # Customer aggregations
│   └── sources.yml                         # Source definitions
│
├── seeds/
│   ├── jaffle_shop_customers.csv           # Customer seed data
│   ├── jaffle_shop_orders.csv              # Order seed data
│   └── jaffle_shop_payments.csv            # Payment seed data
│
├── pr-changes/                              # PR change files
│   ├── pr1/
│   │   └── orders.sql                      # PR #1: Incremental model changes
│   ├── pr2/
│   │   └── staging_orders.sql              # PR #2: Renamed model
│   ├── pr3/
│   │   └── stg_orders.sql                   # PR #3: Timestamp conversion
│   └── README.md                            # PR changes guide
│
├── scripts/
│   ├── setup.sh                            # Automated setup script
│   └── switch-pr.sh                        # PR branch switcher
│
├── .gitignore                               # Git ignore rules
├── .pre-commit-config.yaml                  # Optional: Pre-commit hooks
├── dbt_project.yml                          # dbt project configuration
├── packages.yml                             # dbt packages
├── profiles.yml.example                     # dbt profiles template
├── requirements.txt                         # Python dependencies
├── README.md                                # Main documentation
├── QUICK_START.md                           # 5-minute setup guide
└── REPOSITORY_STRUCTURE.md                  # This file
```

## Key Files Explained

### Configuration Files
- **`dbt_project.yml`**: Main dbt project config with materialization settings
- **`profiles.yml.example`**: Template for DuckDB connection (copy to `profiles.yml`)
- **`packages.yml`**: dbt package dependencies
- **`requirements.txt`**: Python dependencies (dbt-duckdb, recce)

### Models
- **Staging** (`models/staging/`): Raw data transformations
- **Intermediate** (`models/intermediate/`): Business logic aggregations
- **Marts** (`models/marts/`): Final business-facing models

### PR Training Materials
- **`.github/pull_requests/`**: Detailed PR descriptions with expected Recce findings
- **`pr-changes/`**: Modified files for each PR branch
- **`.github/PR_SETUP.md`**: Instructions to create PR branches

### Helper Scripts
- **`scripts/setup.sh`**: Automated environment setup
- **`scripts/switch-pr.sh`**: Quick PR branch switching

### Documentation
- **`README.md`**: Complete training documentation
- **`QUICK_START.md`**: 5-minute setup guide
- **`.github/validation-checklist.md`**: Reusable validation template

## Git Branches (to be created)

After setup, create these branches:

1. **`main`**: Base repository (current state)
2. **`pr1-incremental-filter`**: Incremental model changes
3. **`pr2-model-rename`**: Model rename with breaking change
4. **`pr3-timestamp-logic`**: Timestamp conversion

See `.github/PR_SETUP.md` for branch creation instructions.

## File Count Summary

- **Models**: 6 SQL files
- **Seeds**: 3 CSV files
- **Documentation**: 8+ markdown files
- **Scripts**: 2 shell scripts
- **Config**: 5 YAML files
- **PR Changes**: 3 modified files

**Total**: ~30 files for complete training repository

