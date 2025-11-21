# Super Recce Training Repository

A hands-on training repository for learning Recce with dbt and DuckDB. This project simulates extending a 14-model dbt lineage from one channel (Google Hotel Ads) to two more (Kayak, Trivago) using a modified Jaffle Shop example.

## Getting Started

**New to this repository?** Start with [QUICK_START.md](./QUICK_START.md) for setup instructions.

## Quick Start

See [QUICK_START.md](./QUICK_START.md) for simple step-by-step instructions.

**TL;DR:**
```bash
# Setup (one time)
./scripts/setup.sh

# Run a PR (compares dev to prod data!)
git checkout pr1-incremental-filter
dbt build --target dev       # Creates dev schema data
recce server recce_state.json # Compares dev to prod!
```

## What You'll Learn

This training addresses three critical validation scenarios you'll face when extending your dbt lineage:

### 1. Testing Incremental Model Changes Safely
**Scenario**: You need to modify an incremental model's filter logic (e.g., expanding status filters from `'completed'` to include `'shipped'`).  
**Challenge**: Incremental models can have subtle bugs that only show up over time.  
**Learn**: How Recce's Value Diff and Profile Diff catch incremental logic issues before production.

**See**: [PR #1: Incremental Model Filter Change](./.github/pull_requests/pr1-incremental-filter.md)

### 2. Assessing Downstream Impact of Renaming Models
**Scenario**: You're refactoring model names (e.g., `stg_orders` → `staging_orders`) to improve consistency.  
**Challenge**: Missing a `ref()` update can break production silently.  
**Learn**: How Recce's Breaking Change Analysis and Column-Level Lineage surface all dependencies.

**See**: [PR #2: Model Rename with Breaking Change](./.github/pull_requests/pr2-model-rename.md)

### 3. Validating Timestamp Logic Changes
**Scenario**: Converting timezone handling from EST to UTC across your models.  
**Challenge**: Timestamp changes affect uniqueness, surrogate keys, and incremental logic downstream.  
**Learn**: How Recce's Value Diff and Profile Diff validate timestamp transformations.

**See**: [PR #3: Timestamp Field Logic Change](./.github/pull_requests/pr3-timestamp-logic.md)

## Repository Structure

```
super-recce-training/
├── models/
│   ├── staging/          # Staging layer (raw → cleaned)
│   ├── intermediate/     # Intermediate transformations
│   └── marts/            # Final business models
├── seeds/                # CSV seed files (Jaffle Shop data)
├── macros/               # Reusable SQL macros
├── tests/                # Custom dbt tests
├── scripts/              # Helper scripts
├── profiles.yml.example  # dbt profile template
├── dbt_project.yml       # dbt project configuration
└── README.md             # This file
```

## PR Walkthrough

This repository contains three strategic pull requests, each demonstrating a different Recce validation pattern:

### PR #1: Incremental Model Filter Change
**Branch**: `pr1-incremental-filter`  
**Focus**: Incremental model validation  
**Key Recce Features**: Value Diff, Profile Diff, Incremental Logic Analysis

### PR #2: Model Rename with Breaking Change
**Branch**: `pr2-model-rename`  
**Focus**: Breaking change detection  
**Key Recce Features**: Impact Analysis, Column-Level Lineage, Dependency Graph

### PR #3: Timestamp Field Logic Change
**Branch**: `pr3-timestamp-logic`  
**Focus**: Timestamp/timezone validation  
**Key Recce Features**: Value Diff, Profile Diff, Uniqueness Validation

## Working with PRs

### Option 1: Manual Branch Switching
```bash
# View available PRs
git branch -a

# Switch to a PR branch
git checkout pr1-incremental-filter

# Rebuild models
dbt build

# Run Recce comparison
recce run
```

### Option 2: Using Helper Script
```bash
# Switch to PR #1 and rebuild
./scripts/switch-pr.sh 1

# This will:
# 1. Checkout the PR branch
# 2. Run dbt build
# 3. Generate artifacts
# 4. Show Recce comparison results
```

## Applying to Your Real Models

### Mapping This Training to Your Work

| Training Scenario | Your Real Use Case |
|------------------|-------------------|
| Incremental filter change | Extending channel filters (Google → Kayak, Trivago) |
| Model rename | Refactoring staging layer for new channels |
| Timestamp logic | Timezone standardization across channels |

### Validation Checklist Template

Before merging any PR in your real project:

- [ ] **Breaking Changes**: Review Recce's breaking change report
- [ ] **Value Diffs**: Check for unexpected value changes (>5% threshold)
- [ ] **Profile Diffs**: Verify column distributions are reasonable
- [ ] **Downstream Impact**: Confirm all `ref()` calls are updated
- [ ] **Incremental Logic**: Validate incremental strategy still works
- [ ] **Uniqueness**: Check surrogate keys remain unique

See [`.github/validation-checklist.md`](./.github/validation-checklist.md) for a reusable template.

## Troubleshooting

### DuckDB Connection Issues

**Error**: `Database file is locked`  
**Solution**: Close any other connections to the DuckDB file, or use separate files for dev/prod targets.

**Error**: `No such table: jaffle_shop.orders`  
**Solution**: Run `dbt seed` first to load the seed data.

### dbt Build Fails

**Error**: `Compilation Error: Could not render`  
**Solution**: Check that all `ref()` calls use correct model names. Use `dbt list` to see available models.

**Error**: `Profile 'super' not found`  
**Solution**: Ensure `profiles.yml` exists in `~/.dbt/` or project root, and matches `profiles.yml.example`.

### Recce Issues

**Error**: `No baseline found`  
**Solution**: Run `recce run` with a baseline. For PR comparisons, ensure you've built both the main branch and PR branch.

**Error**: `Artifacts not found`  
**Solution**: Run `dbt compile` or `dbt build` first to generate `target/manifest.json` and `target/run_results.json`.

## Next Steps

1. **Complete the Quick Start** above
2. **Review each PR** in order (PR #1 → PR #2 → PR #3)
3. **Run Recce comparisons** for each PR
4. **Review the validation checklists** in each PR description
5. **Apply the patterns** to your real dbt project

## Resources

- [Recce Documentation](https://docs.recce.dev)
- [Recce Cloud Setup Guide](.github/RECCE_CLOUD_SETUP.md)
- [dbt Documentation](https://docs.getdbt.com)
- [DuckDB Documentation](https://duckdb.org/docs/)

## Support

For questions about this training:
- Check the PR descriptions in `.github/pull_requests/`
- Review the troubleshooting section above
- Consult Recce Cloud documentation

---

**Training Duration**: 45 minutes  
**Prerequisites**: Basic dbt knowledge
**Environment**: Local DuckDB (no warehouse required)

