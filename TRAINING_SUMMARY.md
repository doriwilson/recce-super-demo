# Super Recce Training - Quick Summary

## Overview

This repository provides a 45-minute hands-on training for teaching Recce to data analysts at Super. The training simulates extending a 14-model dbt lineage from one channel (Google Hotel Ads) to two more (Kayak, Trivago).

## Repository Structure

```
recce-super-demo/
├── jaffle-shop/              # Base dbt project (DuckDB)
│   ├── models/
│   │   ├── staging/          # 6 staging models
│   │   └── marts/            # 6 marts models
│   └── seeds/                # Seed data
├── pr-changes/               # PR change files
│   ├── pr1/                  # Incremental model changes
│   ├── pr2/                  # Model rename changes
│   └── pr3/                  # Timestamp changes
├── TRAINING_PLAN.md          # Detailed training plan
├── IMPLEMENTATION_GUIDE.md    # Step-by-step implementation
└── TRAINING_SUMMARY.md       # This file
```

## The 3 PRs

### PR #1: Channel Expansion (Incremental Model)
**Focus**: Extending channel filters from Google-only to Google + Kayak + Trivago  
**Change**: Convert `orders` model to incremental with expanded channel filter  
**Recce Features**: Value Diff, Profile Diff, Incremental Logic Validation  
**Time**: 15 minutes

### PR #2: Model Rename (Breaking Change)
**Focus**: Refactoring staging layer for multi-channel support  
**Change**: Rename `stg_orders` → `staging_orders` (intentionally break downstream)  
**Recce Features**: Breaking Change Detection, Dependency Graph, Column-Level Lineage  
**Time**: 15 minutes

### PR #3: Timestamp Timezone (Data Validation)
**Focus**: Standardizing timestamps from EST to UTC across channels  
**Change**: Convert `ordered_at` from EST to UTC (+5 hours)  
**Recce Features**: Value Diff, Profile Diff, Uniqueness Validation  
**Time**: 15 minutes

## Quick Start

### Setup (5 min)
```bash
cd jaffle-shop
python3 -m venv venv
source venv/bin/activate
pip install dbt-duckdb recce
cp ../profiles.yml.example ~/.dbt/profiles.yml
dbt build
```

### Run Training
```bash
# PR #1
git checkout pr1-channel-expansion
dbt build && recce run

# PR #2
git checkout pr2-model-rename
dbt build && recce run

# PR #3
git checkout pr3-timestamp-timezone
dbt build && recce run
```

## Key Recce Features Demonstrated

| Feature | PR #1 | PR #2 | PR #3 |
|---------|-------|-------|-------|
| Value Diff | ✅ | ✅ | ✅ |
| Profile Diff | ✅ | - | ✅ |
| Breaking Changes | - | ✅ | - |
| Dependency Graph | - | ✅ | - |
| Incremental Validation | ✅ | - | - |
| Uniqueness Check | - | - | ✅ |

## Mapping to Real Work

| Training Scenario | Real Use Case |
|------------------|---------------|
| Incremental filter expansion | Adding Kayak, Trivago channels |
| Model rename refactoring | Preparing staging layer for new channels |
| Timestamp timezone conversion | Standardizing timezones across channels |

## Training Flow

1. **Setup** (5 min): Install dependencies, build baseline
2. **PR #1** (15 min): Incremental model validation
3. **PR #2** (15 min): Breaking change detection
4. **PR #3** (15 min): Timestamp validation
5. **Wrap-up** (5 min): Review checklist, Q&A

**Total**: 45 minutes

## Success Criteria

✅ All models build in <30 seconds  
✅ Setup takes <5 minutes  
✅ Training completes in 45 minutes  
✅ Recce findings are clear and educational  
✅ Patterns apply to real channel extension work  

## Documentation Files

- **TRAINING_PLAN.md**: Complete training plan with scenarios
- **IMPLEMENTATION_GUIDE.md**: Step-by-step implementation instructions
- **TRAINING_SUMMARY.md**: This quick reference
- **README.md**: Main repository documentation
- **QUICK_START.md**: Setup instructions

## Next Steps

1. Review **TRAINING_PLAN.md** for detailed scenarios
2. Follow **IMPLEMENTATION_GUIDE.md** to create PRs
3. Test training flow end-to-end
4. Customize for your specific use case

---

**Ready to implement?** Start with `IMPLEMENTATION_GUIDE.md`

