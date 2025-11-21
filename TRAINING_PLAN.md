# Super Recce Training Plan
## Extending dbt Lineage: Google Hotel Ads → Kayak + Trivago

This document outlines the complete plan for building a 45-minute hands-on training repository that teaches Recce to data analysts at Super. The training simulates extending a 14-model dbt lineage from one channel (Google Hotel Ads) to two more (Kayak, Trivago).

## Training Objectives

By the end of this training, analysts will be able to:
1. Use Recce to validate incremental model changes safely
2. Detect breaking changes when refactoring model names
3. Validate timestamp/timezone logic changes across the lineage
4. Apply these patterns to their real channel extension work

## Model Mapping: Jaffle Shop → Hotel Ads Channels

To make the training relevant, we'll map Jaffle Shop concepts to the hotel ads channel scenario:

| Jaffle Shop Concept | Hotel Ads Channel Equivalent |
|---------------------|------------------------------|
| `raw_orders` | Raw booking data from channels |
| `stg_orders` | Staged bookings (currently Google only) |
| `orders` (marts) | Final bookings model (needs to include Kayak, Trivago) |
| `stg_locations` | Hotel locations/stores |
| `locations` (marts) | Final locations model |
| `ordered_at` timestamp | Booking timestamp (needs timezone standardization) |
| Order status filters | Channel filters (Google → Google + Kayak + Trivago) |

## Current State: Baseline (Main Branch)

The baseline represents the current production state with **only Google Hotel Ads**:

### Key Models (14-model lineage)
1. **Staging Layer** (6 models):
   - `stg_customers` - Customer data
   - `stg_orders` - Orders from Google Hotel Ads only
   - `stg_order_items` - Order line items
   - `stg_products` - Product catalog
   - `stg_supplies` - Supply chain data
   - `stg_locations` - Store/location data

2. **Marts Layer** (6 models):
   - `customers` - Customer analytics
   - `orders` - Order analytics (currently Google-only)
   - `order_items` - Order item details
   - `products` - Product catalog
   - `supplies` - Supply analytics
   - `locations` - Location analytics

3. **Intermediate Layer** (2 models):
   - `int_order_payments` - Payment processing
   - `metricflow_time_spine` - Time dimension

### Current Assumptions
- All orders come from `channel = 'google_hotel_ads'`
- Timestamps are in EST timezone
- `orders` model is a view (not incremental)
- No channel-specific filtering in staging layer

## PR #1: Extending Channel Filters (Incremental Model Change)

### Business Scenario
**Goal**: Extend the `orders` model to include bookings from Kayak and Trivago, not just Google Hotel Ads.

**Challenge**: The `orders` model needs to become incremental to handle the increased volume, and we need to safely validate that the filter expansion doesn't break existing logic.

### Technical Changes

#### File: `models/marts/orders.sql`
**Change**: Convert from view to incremental model with expanded channel filter

**Before** (baseline):
```sql
-- Simple view, no channel filtering (assumes all data is Google)
select * from {{ ref('stg_orders') }}
```

**After** (PR #1):
```sql
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='append_new_columns'
    )
}}

select * from {{ ref('stg_orders') }}
where channel in ('google_hotel_ads', 'kayak', 'trivago')  -- Expanded filter
{% if is_incremental() %}
    and ordered_at > (select max(ordered_at) from {{ this }})
{% endif %}
```

### What Recce Will Catch

1. **Value Diff**:
   - Row count increase (expected: ~3x if all channels have similar volume)
   - New channel values appear in data
   - Aggregate metrics change (total orders, revenue)

2. **Profile Diff**:
   - New `channel` column values
   - Distribution changes in order amounts
   - Timestamp ranges expand

3. **Incremental Logic Validation**:
   - Verify incremental strategy works correctly
   - Check that `unique_key` prevents duplicates
   - Validate `on_schema_change` handles new columns

### Expected Recce Findings
- ✅ Row count increases (expected)
- ✅ New channel values in profile
- ⚠️ May flag if incremental logic has issues
- ✅ Downstream models still build successfully

### Training Focus
- How to interpret Value Diff for incremental models
- Validating that incremental strategy works
- Understanding Profile Diff for new categorical values

---

## PR #2: Refactoring Staging Layer (Model Rename + Breaking Change)

### Business Scenario
**Goal**: Refactor staging layer to prepare for multi-channel support. Rename `stg_orders` to `staging_orders` for consistency, but **intentionally miss updating one downstream reference** to demonstrate Recce's breaking change detection.

**Challenge**: Model renames can silently break production if `ref()` calls aren't updated everywhere.

### Technical Changes

#### File: `models/staging/stg_orders.sql` → `models/staging/staging_orders.sql`
**Change**: Rename file and update model name

**Before** (baseline):
- File: `models/staging/stg_orders.sql`
- Model name: `stg_orders`

**After** (PR #2):
- File: `models/staging/staging_orders.sql`
- Model name: `staging_orders`
- **Intentionally NOT updated**: `models/marts/orders.sql` still references `stg_orders`

### What Recce Will Catch

1. **Breaking Changes**:
   - Model `stg_orders` deleted
   - Model `staging_orders` added
   - Downstream model `orders` has broken `ref()` call

2. **Dependency Graph**:
   - Shows all models that depend on `stg_orders`
   - Highlights which models need `ref()` updates

3. **Compilation Errors**:
   - `orders` model will fail to compile
   - Clear error message about missing model

### Expected Recce Findings
- ❌ Breaking change: Model deleted
- ❌ Breaking change: Downstream dependency broken
- ⚠️ Compilation error in `orders` model
- ✅ Shows all affected models in dependency graph

### Training Focus
- Breaking change detection before merge
- Dependency graph visualization
- Column-level lineage impact
- How to fix: Update `ref('stg_orders')` → `ref('staging_orders')` in `orders.sql`

---

## PR #3: Timestamp Timezone Standardization

### Business Scenario
**Goal**: Standardize all booking timestamps from EST to UTC across all models. This is critical when combining data from multiple channels that may have different timezone handling.

**Challenge**: Timestamp changes affect:
- Uniqueness of surrogate keys
- Incremental model logic
- Downstream aggregations
- Time-based filters

### Technical Changes

#### File: `models/staging/stg_orders.sql`
**Change**: Convert `ordered_at` from EST to UTC (+5 hours)

**Before** (baseline):
```sql
{{ dbt.date_trunc('day','ordered_at') }} as ordered_at
```

**After** (PR #3):
```sql
{{ dbt.date_trunc('day', dbt.dateadd('hour', 5, 'ordered_at')) }} as ordered_at_utc,
-- Keep original for comparison during migration
ordered_at as ordered_at_est
```

**Alternative approach** (cleaner):
```sql
-- Convert EST to UTC (EST is UTC-5, so add 5 hours)
{{ dbt.date_trunc('day', 
    dbt.dateadd('hour', 5, 'ordered_at')
) }} as ordered_at
```

### What Recce Will Catch

1. **Value Diff**:
   - All timestamp values shift by +5 hours
   - Date boundaries change (orders may move to different days)
   - Row counts per day may change

2. **Profile Diff**:
   - Min/max timestamp values shift
   - Date distributions change
   - Time-based patterns shift

3. **Uniqueness Validation**:
   - Verify `order_id` still unique
   - Check that incremental logic still works
   - Validate date-based aggregations

4. **Downstream Impact**:
   - Models using `ordered_at` for filtering
   - Time-based metrics in `customers` model
   - Date-based incremental strategies

### Expected Recce Findings
- ✅ All timestamps shift by +5 hours (expected)
- ⚠️ Date boundaries may change (some orders move to next day)
- ✅ Uniqueness preserved
- ✅ Downstream models handle change correctly

### Training Focus
- Validating timestamp transformations
- Understanding timezone impact on date boundaries
- Profile Diff for temporal data
- Downstream impact analysis

---

## Implementation Steps

### Step 1: Set Up Baseline (Main Branch)
1. Ensure all jaffle-shop models build successfully
2. Add channel concept to `stg_orders` (default: 'google_hotel_ads')
3. Document the 14-model lineage
4. Create baseline artifacts: `dbt build` + `dbt compile`

### Step 2: Create PR #1 Branch
```bash
git checkout -b pr1-channel-expansion
# Apply changes to models/marts/orders.sql
dbt build
dbt compile
recce run  # Compare against main branch
```

### Step 3: Create PR #2 Branch
```bash
git checkout main
git checkout -b pr2-model-rename
# Rename stg_orders.sql to staging_orders.sql
# Intentionally leave orders.sql with old ref()
dbt build  # This will fail - that's the point!
recce run  # Show breaking changes
```

### Step 4: Create PR #3 Branch
```bash
git checkout main
git checkout -b pr3-timestamp-timezone
# Update stg_orders.sql timestamp logic
dbt build
dbt compile
recce run  # Show timestamp value diffs
```

## Training Flow (45 minutes)

### Setup (5 min)
- Clone repo, install dependencies
- Run `./scripts/setup.sh`
- Verify `dbt build` works

### PR #1: Incremental Model Changes (15 min)
1. **Context** (2 min): Explain channel expansion scenario
2. **Review Changes** (3 min): Show the incremental model change
3. **Run Recce** (5 min): Execute `recce run` and review results
4. **Interpret Results** (5 min): Walk through Value Diff, Profile Diff, incremental validation

### PR #2: Breaking Change Detection (15 min)
1. **Context** (2 min): Explain refactoring scenario
2. **Review Changes** (3 min): Show model rename
3. **Run Recce** (5 min): Execute `recce run` and see breaking changes
4. **Fix & Validate** (5 min): Update `ref()` call, re-run Recce

### PR #3: Timestamp Validation (15 min)
1. **Context** (2 min): Explain timezone standardization
2. **Review Changes** (3 min): Show timestamp conversion
3. **Run Recce** (5 min): Execute `recce run` and review timestamp diffs
4. **Interpret Results** (5 min): Walk through Value Diff, Profile Diff, uniqueness checks

### Wrap-up (5 min)
- Review validation checklist
- Map training scenarios to real work
- Q&A

## Key Recce Features Demonstrated

### PR #1: Incremental Model Validation
- ✅ Value Diff (row counts, aggregates)
- ✅ Profile Diff (new channel values)
- ✅ Incremental strategy validation
- ✅ Schema change handling

### PR #2: Breaking Change Detection
- ✅ Breaking change analysis
- ✅ Dependency graph visualization
- ✅ Column-level lineage
- ✅ Compilation error detection

### PR #3: Timestamp Validation
- ✅ Value Diff (timestamp shifts)
- ✅ Profile Diff (date distributions)
- ✅ Uniqueness validation
- ✅ Downstream impact analysis

## Success Criteria

✅ All 3 PRs demonstrate distinct Recce capabilities  
✅ Training can be completed in 45 minutes  
✅ Scenarios map clearly to real channel extension work  
✅ Analysts can apply patterns to their actual dbt projects  
✅ Setup takes <5 minutes  
✅ All models build in <30 seconds  

## Next Steps

1. **Implement baseline models** with channel concept
2. **Create PR #1** with incremental model changes
3. **Create PR #2** with intentional breaking change
4. **Create PR #3** with timestamp timezone conversion
5. **Write PR documentation** for each scenario
6. **Create helper scripts** for PR switching
7. **Test training flow** end-to-end

---

**Status**: Plan Complete - Ready for Implementation

