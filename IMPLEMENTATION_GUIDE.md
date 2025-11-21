# Implementation Guide: Super Recce Training Repository

This guide provides step-by-step instructions for implementing the 3 PRs using the jaffle-shop models in the `jaffle-shop/` directory.

## Overview

We'll adapt the existing jaffle-shop models to simulate extending from Google Hotel Ads to Kayak + Trivago by:
1. Adding a `channel` concept to orders
2. Creating 3 PRs that demonstrate Recce's validation capabilities
3. Mapping training scenarios to real channel extension work

## Prerequisites

- DuckDB installed and configured
- dbt-duckdb adapter installed
- Recce installed
- jaffle-shop models building successfully

## Step 1: Prepare Baseline (Main Branch)

### 1.1 Add Channel Concept to Staging Orders

**File**: `jaffle-shop/models/staging/stg_orders.sql`

**Current state** (baseline):
```sql
with

source as (
    select * from {{ source('ecom', 'raw_orders') }}
),

renamed as (
    select
        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- numerics
        subtotal as subtotal_cents,
        tax_paid as tax_paid_cents,
        order_total as order_total_cents,
        {{ cents_to_dollars('subtotal') }} as subtotal,
        {{ cents_to_dollars('tax_paid') }} as tax_paid,
        {{ cents_to_dollars('order_total') }} as order_total,

        ---------- timestamps
        {{ dbt.date_trunc('day','ordered_at') }} as ordered_at

    from source
)

select * from renamed
```

**Modified baseline** (add channel, default to 'google_hotel_ads'):
```sql
with

source as (
    select * from {{ source('ecom', 'raw_orders') }}
),

renamed as (
    select
        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- numerics
        subtotal as subtotal_cents,
        tax_paid as tax_paid_cents,
        order_total as order_total_cents,
        {{ cents_to_dollars('subtotal') }} as subtotal,
        {{ cents_to_dollars('tax_paid') }} as tax_paid,
        {{ cents_to_dollars('order_total') }} as order_total,

        ---------- timestamps
        {{ dbt.date_trunc('day','ordered_at') }} as ordered_at,

        ---------- channel (baseline: all orders from Google Hotel Ads)
        'google_hotel_ads' as channel

    from source
)

select * from renamed
```

### 1.2 Verify Baseline Builds

```bash
cd jaffle-shop
dbt build
dbt compile
```

**Expected**: All models build successfully, ~14 models total.

### 1.3 Commit Baseline

```bash
git add .
git commit -m "Baseline: Google Hotel Ads only (14 models)"
```

---

## Step 2: Create PR #1 - Channel Expansion (Incremental Model)

### 2.1 Create Branch

```bash
git checkout -b pr1-channel-expansion
```

### 2.2 Modify Orders Mart Model

**File**: `jaffle-shop/models/marts/orders.sql`

**Current state** (view materialization):
```sql
with

orders as (
    select * from {{ ref('stg_orders') }}
),
...
```

**PR #1 changes** (convert to incremental, add channel filter):
```sql
{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='append_new_columns'
    )
}}

with

orders as (
    select * from {{ ref('stg_orders') }}
    -- PR #1: Expand channel filter to include Kayak and Trivago
    -- In baseline, this would only be 'google_hotel_ads'
    where channel in ('google_hotel_ads', 'kayak', 'trivago')
    {% if is_incremental() %}
        and ordered_at > (select max(ordered_at) from {{ this }})
    {% endif %}
),

order_items as (
    select * from {{ ref('order_items') }}
),
...
```

**Note**: Since the baseline only has 'google_hotel_ads' data, this filter will work but won't show new data yet. For training purposes, we can:
- Option A: Simulate by temporarily adding test data with other channels
- Option B: Focus on the incremental logic validation itself
- Option C: Use Recce's value diff to show the filter change impact

### 2.3 Update Staging to Include Multiple Channels (Optional)

For a more realistic demo, we can modify the seed data or staging to simulate multiple channels:

**File**: `jaffle-shop/models/staging/stg_orders.sql` (PR #1 version)

```sql
with

source as (
    select * from {{ source('ecom', 'raw_orders') }}
),

renamed as (
    select
        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- numerics
        subtotal as subtotal_cents,
        tax_paid as tax_paid_cents,
        order_total as order_total_cents,
        {{ cents_to_dollars('subtotal') }} as subtotal,
        {{ cents_to_dollars('tax_paid') }} as tax_paid,
        {{ cents_to_dollars('order_total') }} as order_total,

        ---------- timestamps
        {{ dbt.date_trunc('day','ordered_at') }} as ordered_at,

        ---------- channel (PR #1: Now includes multiple channels)
        -- Simulate channel distribution: 50% Google, 30% Kayak, 20% Trivago
        case 
            when mod(cast(id as integer), 10) < 5 then 'google_hotel_ads'
            when mod(cast(id as integer), 10) < 8 then 'kayak'
            else 'trivago'
        end as channel

    from source
)

select * from renamed
```

### 2.4 Build and Test PR #1

```bash
dbt build
dbt compile
```

### 2.5 Run Recce Comparison

```bash
# From main branch, build baseline
git checkout main
dbt build
dbt compile

# Switch to PR branch
git checkout pr1-channel-expansion
dbt build
dbt compile

# Run Recce comparison
recce run
```

### 2.6 Expected Recce Findings

- **Value Diff**: Row count may increase (if we added channel simulation)
- **Profile Diff**: New channel values appear ('kayak', 'trivago')
- **Incremental Logic**: Validates unique_key and incremental strategy
- **Schema Changes**: Tests `on_schema_change='append_new_columns'`

### 2.7 Commit PR #1

```bash
git add .
git commit -m "PR #1: Convert orders to incremental, expand channel filter"
```

---

## Step 3: Create PR #2 - Model Rename (Breaking Change)

### 3.1 Create Branch from Main

```bash
git checkout main
git checkout -b pr2-model-rename
```

### 3.2 Rename Staging Orders Model

**Action**: Rename file and update model name

```bash
# Rename the file
mv jaffle-shop/models/staging/stg_orders.sql jaffle-shop/models/staging/staging_orders.sql
```

**File**: `jaffle-shop/models/staging/staging_orders.sql`

**Update model name** (if using dbt's model name from file):
```sql
-- No explicit model name needed, dbt uses filename
-- But we should update any explicit config if present
```

**IMPORTANT**: Do NOT update `jaffle-shop/models/marts/orders.sql` - leave it with `{{ ref('stg_orders') }}` to create the breaking change.

### 3.3 Attempt Build (Will Fail)

```bash
dbt build
```

**Expected**: Compilation error - `stg_orders` model not found.

### 3.4 Run Recce to See Breaking Changes

```bash
# Build baseline first
git checkout main
dbt build
dbt compile

# Switch to PR
git checkout pr2-model-rename
dbt compile  # This will fail, but Recce can still analyze

recce run
```

### 3.5 Expected Recce Findings

- **Breaking Changes**: 
  - Model `stg_orders` deleted
  - Model `staging_orders` added
  - Downstream model `orders` has broken reference
- **Dependency Graph**: Shows all models depending on `stg_orders`
- **Compilation Errors**: Clear error messages

### 3.6 Fix the Breaking Change (For Training)

Update `jaffle-shop/models/marts/orders.sql`:

```sql
orders as (
    select * from {{ ref('staging_orders') }}  -- Fixed: was stg_orders
),
```

Then rebuild and re-run Recce to show the fix.

### 3.7 Commit PR #2

```bash
git add .
git commit -m "PR #2: Rename stg_orders to staging_orders (intentional breaking change)"
```

---

## Step 4: Create PR #3 - Timestamp Timezone Conversion

### 4.1 Create Branch from Main

```bash
git checkout main
git checkout -b pr3-timestamp-timezone
```

### 4.2 Modify Staging Orders Timestamp

**File**: `jaffle-shop/models/staging/stg_orders.sql`

**Current state** (baseline):
```sql
{{ dbt.date_trunc('day','ordered_at') }} as ordered_at,
```

**PR #3 changes** (convert EST to UTC):
```sql
-- PR #3: Convert from EST to UTC (EST is UTC-5, so add 5 hours)
-- In production, use warehouse-specific timezone functions
-- For DuckDB: we can use interval arithmetic
{{ dbt.date_trunc('day', 
    dbt.dateadd('hour', 5, 'ordered_at')
) }} as ordered_at,
-- Keep original for comparison (optional, for training)
-- ordered_at as ordered_at_est
```

**DuckDB-specific syntax**:
```sql
-- DuckDB uses different syntax - check dbt-duckdb adapter capabilities
-- Alternative approach if dateadd doesn't work:
date_trunc('day', ordered_at + interval '5 hours') as ordered_at,
```

### 4.3 Build and Test PR #3

```bash
dbt build
dbt compile
```

### 4.4 Run Recce Comparison

```bash
# From main branch
git checkout main
dbt build
dbt compile

# Switch to PR
git checkout pr3-timestamp-timezone
dbt build
dbt compile

# Run Recce
recce run
```

### 4.5 Expected Recce Findings

- **Value Diff**: 
  - All `ordered_at` timestamps shift by +5 hours
  - Some orders may move to different days (date boundary changes)
  - Row counts per day may change
- **Profile Diff**:
  - Min/max timestamp values shift
  - Date distributions change
- **Uniqueness**: Verify `order_id` still unique
- **Downstream Impact**: Check models using `ordered_at` (e.g., `customers` model with `first_ordered_at`, `last_ordered_at`)

### 4.6 Commit PR #3

```bash
git add .
git commit -m "PR #3: Convert timestamps from EST to UTC"
```

---

## Step 5: Create PR Documentation

For each PR, create detailed documentation:

### PR #1 Documentation

**File**: `.github/pull_requests/pr1-channel-expansion.md`

Include:
- Business scenario explanation
- Technical changes made
- Expected Recce findings
- Validation checklist
- How to run the comparison

### PR #2 Documentation

**File**: `.github/pull_requests/pr2-model-rename.md`

Include:
- Refactoring scenario
- Breaking change details
- How Recce detects it
- How to fix
- Dependency graph interpretation

### PR #3 Documentation

**File**: `.github/pull_requests/pr3-timestamp-timezone.md`

Include:
- Timezone standardization scenario
- Timestamp conversion logic
- Expected value shifts
- Downstream impact analysis
- Uniqueness validation

---

## Step 6: Update Helper Scripts

### Update `scripts/switch-pr.sh`

Ensure it works with the jaffle-shop directory structure:

```bash
#!/bin/bash
PR_NUM=$1

cd jaffle-shop  # Navigate to jaffle-shop directory

case $PR_NUM in
  1)
    git checkout pr1-channel-expansion
    ;;
  2)
    git checkout pr2-model-rename
    ;;
  3)
    git checkout pr3-timestamp-timezone
    ;;
  *)
    echo "Usage: ./scripts/switch-pr.sh [1|2|3]"
    exit 1
    ;;
esac

dbt build
dbt compile
echo "Switched to PR #$PR_NUM. Run 'recce run' to compare."
```

---

## Step 7: Testing the Training Flow

### Test Each PR

1. **PR #1 Test**:
   ```bash
   ./scripts/switch-pr.sh 1
   recce run
   # Verify: Incremental logic, channel expansion, value diffs
   ```

2. **PR #2 Test**:
   ```bash
   ./scripts/switch-pr.sh 2
   recce run
   # Verify: Breaking changes detected, dependency graph
   ```

3. **PR #3 Test**:
   ```bash
   ./scripts/switch-pr.sh 3
   recce run
   # Verify: Timestamp shifts, profile diffs, uniqueness
   ```

### Full Training Run-Through

1. Start from main branch
2. Run through each PR in order
3. Verify Recce findings match expectations
4. Ensure training can be completed in 45 minutes

---

## Mapping to Real Use Case

### Channel Extension Workflow

| Training PR | Real Use Case | Recce Feature |
|-------------|---------------|---------------|
| PR #1: Incremental + Channel Filter | Adding Kayak, Trivago channels | Value Diff, Profile Diff, Incremental Validation |
| PR #2: Model Rename | Refactoring staging for multi-channel | Breaking Change Detection, Dependency Graph |
| PR #3: Timestamp Conversion | Standardizing timezones across channels | Value Diff, Profile Diff, Uniqueness Check |

---

## Troubleshooting

### Issue: Models don't build after PR changes

**Solution**: 
- Check `dbt compile` for syntax errors
- Verify all `ref()` calls are correct
- Ensure seed data is loaded: `dbt seed`

### Issue: Recce shows no differences

**Solution**:
- Ensure baseline was built: `git checkout main && dbt build`
- Verify PR branch has changes: `git diff main`
- Check Recce is comparing correct artifacts

### Issue: DuckDB timezone functions don't work

**Solution**:
- Use DuckDB's native interval arithmetic: `ordered_at + interval '5 hours'`
- Or use dbt macros if available in dbt-duckdb adapter
- Check DuckDB documentation for timezone functions

---

## Success Checklist

- [ ] Baseline builds successfully with channel concept
- [ ] PR #1 demonstrates incremental model validation
- [ ] PR #2 demonstrates breaking change detection
- [ ] PR #3 demonstrates timestamp validation
- [ ] All PRs have documentation
- [ ] Helper scripts work correctly
- [ ] Training can be completed in 45 minutes
- [ ] Recce findings are clear and educational

---

**Status**: Implementation Guide Complete

