# Super Recce Training Repository

A hands-on training repository for learning Recce with dbt and DuckDB. This project simulates extending a 14-model dbt lineage from one channel (Google Hotel Ads) to two more (Kayak, Trivago) using a modified Jaffle Shop example.

## Quick Start

**New to this repository?** Start with [QUICK_START.md](./QUICK_START.md) - it has everything you need!

**TL;DR:**
```bash
# Setup (one time)
./scripts/setup.sh

# Run a PR (compares dev to prod data!)
git checkout pr1-incremental-filter
dbt build --target dev
recce server recce_state.json
```

## What You'll Learn

This training addresses three critical validation scenarios:

### 1. Testing Incremental Model Changes Safely
**Scenario**: Modifying an incremental model's filter logic  
**Learn**: How Recce's Value Diff and Profile Diff catch incremental logic issues  
**See**: [PR #1](./.github/pull_requests/pr1-incremental-filter.md)

### 2. Assessing Downstream Impact of Renaming Models
**Scenario**: Refactoring model names & column name.
**Learn**: How Recce's Breaking Change Analysis surfaces all dependencies  
**See**: [PR #2](./.github/pull_requests/pr2-model-rename.md)

### 3. Validating Timestamp Logic Changes
**Scenario**: Converting timezone handling (EST → UTC)  
**Learn**: How Recce's Value Diff and Profile Diff validate timestamp transformations  
**See**: [PR #3](./.github/pull_requests/pr3-timestamp-logic.md)

## How It Works

**Production vs Development Data Comparison:**
- Main branch builds to `prod` schema (base/production data)
- PR branches build to `dev` schema (development data)
- Recce queries both schemas for actual data comparisons
- Shows real differences: row counts, values, distributions

**Pre-Generated State Files:**
- `target-base/` on main: Prod artifacts
- `recce_state.json` on each PR branch: Comparison setup
- No manual state file generation needed!

## Repository Structure

```
super-recce-training/
├── models/
│   ├── staging/          # Staging layer
│   ├── intermediate/     # Intermediate transformations
│   └── marts/            # Final business models
├── seeds/                # CSV seed files
├── scripts/              # Helper scripts
│   ├── setup.sh          # Automated setup
│   └── switch-pr.sh      # Quick PR switching
├── profiles.yml.example  # dbt profile template
└── QUICK_START.md        # Start here!
```

## PR Walkthrough

Three strategic pull requests, each demonstrating a different Recce validation pattern:

- **PR #1** (`pr1-incremental-filter`): Incremental model validation
- **PR #2** (`pr2-model-rename`): Breaking change detection
- **PR #3** (`pr3-timestamp-logic`): Timestamp/timezone validation

See [QUICK_START.md](./QUICK_START.md) for how to run each PR.

## Applying to Your Real Models

| Training Scenario | Your Real Use Case |
|------------------|-------------------|
| Incremental filter change | Extending channel filters (Google → Kayak, Trivago) |
| Model rename | Refactoring staging layer for new channels |
| Timestamp logic | Timezone standardization across channels |

See [`.github/validation-checklist.md`](./.github/validation-checklist.md) for a reusable template.

## Troubleshooting

**"Profile 'super' not found"**
- Run: `cp profiles.yml.example profiles.yml`

**"No such table: jaffle_shop.orders"**
- Run: `dbt seed` first

**"Database file is locked"**
- Close other connections or delete `super_training.duckdb` and rebuild

**"Cannot load the manifest"**
- Run: `dbt build --target dev` first

## Resources

- [Recce Documentation](https://docs.recce.dev)
- [dbt Documentation](https://docs.getdbt.com)

## Support

For questions:
- Check [QUICK_START.md](./QUICK_START.md) for setup
- Review PR descriptions in `.github/pull_requests/`
- See troubleshooting section above

---

**Training Duration**: 45 minutes  
**Prerequisites**: Python 3.8+, Basic dbt knowledge  
**Environment**: Local DuckDB (no warehouse required)
