# Repository Summary: Super Recce Training

This document provides a complete overview of the training repository structure and how all components work together.

## Repository Structure

```
recce-super-demo/
├── .github/
│   ├── workflows/
│   │   └── recce-ci.yml              # GitHub Actions workflow for Recce Cloud CI
│   ├── pull_requests/
│   │   ├── pr1-incremental-filter.md # PR #1 documentation
│   │   ├── pr2-model-rename.md       # PR #2 documentation
│   │   └── pr3-timestamp-logic.md     # PR #3 documentation
│   ├── RECCE_CLOUD_SETUP.md          # Recce Cloud CI setup guide
│   ├── PR_SETUP.md                   # Guide for creating PR branches
│   └── validation-checklist.md       # Reusable validation checklist
│
├── models/
│   ├── staging/
│   │   ├── stg_customers.sql         # Base staging model
│   │   ├── stg_orders.sql            # Base staging model (modified in PR #2, #3)
│   │   └── stg_payments.sql          # Base staging model
│   ├── intermediate/
│   │   └── int_order_payments.sql    # Payment aggregations
│   ├── marts/
│   │   ├── orders.sql                # Base mart model (modified in PR #1)
│   │   └── customer_orders.sql        # Customer aggregations
│   └── sources.yml                   # Source definitions
│
├── seeds/
│   ├── jaffle_shop_customers.csv     # Seed data
│   ├── jaffle_shop_orders.csv        # Seed data
│   └── jaffle_shop_payments.csv      # Seed data
│
├── pr-changes/                       # PR change files (for reference)
│   ├── pr1/
│   │   └── orders.sql                # PR #1 changes
│   ├── pr2/
│   │   └── staging_orders.sql        # PR #2 changes
│   └── pr3/
│       └── stg_orders.sql            # PR #3 changes
│
├── scripts/
│   ├── setup.sh                      # Automated setup script
│   └── switch-pr.sh                  # PR branch switching helper
│
├── dbt_project.yml                   # dbt project configuration
├── profiles.yml.example              # dbt profiles template
├── requirements.txt                  # Python dependencies
├── README.md                         # Main documentation
├── QUICK_START.md                    # Quick start guide
└── .gitignore                        # Git ignore rules
```

## Component Overview

### 1. Base Models (Main Branch)

**Staging Layer** (`models/staging/`):
- `stg_customers.sql`: Simple customer staging
- `stg_orders.sql`: Order staging (will be modified in PR #2 and #3)
- `stg_payments.sql`: Payment staging

**Intermediate Layer** (`models/intermediate/`):
- `int_order_payments.sql`: Aggregates payments by order

**Marts Layer** (`models/marts/`):
- `orders.sql`: Final orders mart (will be modified in PR #1)
- `customer_orders.sql`: Customer-level aggregations

### 2. Three Training PRs

#### PR #1: Incremental Model Filter Change
- **Branch**: `pr1-incremental-filter`
- **Change**: Convert `orders.sql` to incremental with expanded status filter
- **Learning**: Incremental model validation with Recce
- **Files**: `models/marts/orders.sql`

#### PR #2: Model Rename with Breaking Change
- **Branch**: `pr2-model-rename`
- **Change**: Rename `stg_orders` → `staging_orders` (intentionally breaks `orders.sql`)
- **Learning**: Breaking change detection
- **Files**: 
  - Rename: `models/staging/stg_orders.sql` → `models/staging/staging_orders.sql`
  - **Not updated**: `models/marts/orders.sql` (intentional break)

#### PR #3: Timestamp Field Logic Change
- **Branch**: `pr3-timestamp-logic`
- **Change**: Convert `order_date` from EST to UTC in `stg_orders.sql`
- **Learning**: Timestamp/timezone validation
- **Files**: `models/staging/stg_orders.sql`

### 3. CI/CD Integration

**GitHub Actions Workflow** (`.github/workflows/recce-ci.yml`):
- Automatically runs on PRs to `main`
- Builds baseline from `main` branch
- Builds PR branch
- Runs Recce Cloud comparison
- Posts results as PR comment

**Setup Required**:
1. Add `RECCE_API_KEY` to GitHub Secrets
2. (Optional) Add `RECCE_PROJECT_ID` if using multiple projects
3. Workflow runs automatically

### 4. Helper Scripts

**`scripts/setup.sh`**:
- Creates Python virtual environment
- Installs dependencies (dbt-duckdb, recce)
- Sets up profiles.yml
- Seeds database
- Builds dbt project
- Generates artifacts

**`scripts/switch-pr.sh`**:
- Quickly switches between PR branches
- Rebuilds models
- Generates artifacts
- Usage: `./scripts/switch-pr.sh 1` (for PR #1)

### 5. Documentation

**Main Documentation**:
- `README.md`: Complete repository overview
- `QUICK_START.md`: 5-minute setup guide
- `.github/RECCE_CLOUD_SETUP.md`: Recce Cloud CI setup

**PR Documentation**:
- `.github/pull_requests/pr1-incremental-filter.md`: PR #1 details
- `.github/pull_requests/pr2-model-rename.md`: PR #2 details
- `.github/pull_requests/pr3-timestamp-logic.md`: PR #3 details

**Templates**:
- `.github/validation-checklist.md`: Reusable validation checklist
- `.github/PR_SETUP.md`: Guide for creating PR branches

## Training Flow

### Setup (5 minutes)
1. Clone repository
2. Run `./scripts/setup.sh`
3. Verify: `dbt build` completes successfully

### PR #1: Incremental Model Changes (15 minutes)
1. Switch to `pr1-incremental-filter` branch
2. Review changes in `models/marts/orders.sql`
3. Run `dbt build`
4. Run `recce run` to see Value Diff and Profile Diff
5. Review findings in Recce report

### PR #2: Breaking Change Detection (15 minutes)
1. Switch to `pr2-model-rename` branch
2. Review breaking change (missing `ref()` update)
3. Run `dbt build` (should fail)
4. Run `recce run` to see Breaking Change Analysis
5. Fix the issue and verify

### PR #3: Timestamp Validation (15 minutes)
1. Switch to `pr3-timestamp-logic` branch
2. Review timezone conversion in `stg_orders.sql`
3. Run `dbt build`
4. Run `recce run` to see Value Diff for timestamps
5. Review Profile Diff for date distributions

**Total Time**: ~45 minutes

## Key Learning Outcomes

After completing this training, analysts will understand:

1. **Incremental Model Validation**
   - How Recce catches incremental logic issues
   - Value Diff for row count changes
   - Profile Diff for distribution changes

2. **Breaking Change Detection**
   - How Recce identifies missing `ref()` updates
   - Dependency graph visualization
   - Column-level lineage impact

3. **Timestamp/Timezone Validation**
   - How Recce validates timezone conversions
   - Value Diff for date shifts
   - Profile Diff for date distributions
   - Uniqueness validation

4. **CI/CD Integration**
   - How Recce Cloud works in GitHub Actions
   - Automated PR validation
   - Results posted as PR comments

## Real-World Application

This training directly maps to the analysts' actual work:

| Training Scenario | Real Use Case |
|------------------|---------------|
| Incremental filter change | Extending channel filters (Google → Kayak, Trivago) |
| Model rename | Refactoring staging layer for new channels |
| Timestamp logic | Timezone standardization across channels |

## Next Steps After Training

1. **Apply to Real Project**
   - Use validation checklist for real PRs
   - Set up Recce Cloud CI for your repository
   - Review Recce reports before merging

2. **Customize for Your Team**
   - Adjust validation thresholds
   - Add team-specific checks
   - Create custom PR templates

3. **Continuous Learning**
   - Review Recce documentation
   - Experiment with different scenarios
   - Share learnings with team

## Support Resources

- **Recce Documentation**: https://docs.recce.dev
- **Recce Cloud**: https://cloud.recce.dev
- **dbt Documentation**: https://docs.getdbt.com
- **DuckDB Documentation**: https://duckdb.org/docs/

---

**Repository Status**: ✅ Complete and ready for training

**Last Updated**: Repository is fully configured with all PRs, CI/CD, and documentation.

