# Detailed PR Changes for Super Recce Training

This document shows the exact code changes needed for each PR, using the jaffle-shop models.

## Model Lineage Overview

```
raw_orders (source)
    ↓
stg_orders (staging)
    ↓
orders (marts) ──→ customers (marts)
    ↓
order_items (marts)
```

**Total**: 14 models (6 staging + 6 marts + 2 intermediate)

---

## PR #1: Channel Expansion (Incremental Model)

### Change 1: Add Channel to Staging Orders

**File**: `jaffle-shop/models/staging/stg_orders.sql`

**Baseline**:
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

**PR #1 Change** (add channel simulation):
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

        ---------- channel (PR #1: Simulate multi-channel data)
        -- Distribution: 50% Google, 30% Kayak, 20% Trivago
        case 
            when mod(cast(id as integer), 10) < 5 then 'google_hotel_ads'
            when mod(cast(id as integer), 10) < 8 then 'kayak'
            else 'trivago'
        end as channel

    from source
)

select * from renamed
```

### Change 2: Convert Orders Mart to Incremental

**File**: `jaffle-shop/models/marts/orders.sql`

**Baseline** (view materialization):
```sql
with

orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('order_items') }}
),

order_items_summary as (
    select
        order_id,
        sum(supply_cost) as order_cost,
        sum(product_price) as order_items_subtotal,
        count(order_item_id) as count_order_items,
        sum(
            case
                when is_food_item then 1
                else 0
            end
        ) as count_food_items,
        sum(
            case
                when is_drink_item then 1
                else 0
            end
        ) as count_drink_items
    from order_items
    group by 1
),

compute_booleans as (
    select
        orders.*,
        order_items_summary.order_cost,
        order_items_summary.order_items_subtotal,
        order_items_summary.count_food_items,
        order_items_summary.count_drink_items,
        order_items_summary.count_order_items,
        order_items_summary.count_food_items > 0 as is_food_order,
        order_items_summary.count_drink_items > 0 as is_drink_order
    from orders
    left join
        order_items_summary
        on orders.order_id = order_items_summary.order_id
),

customer_order_count as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by ordered_at asc
        ) as customer_order_number
    from compute_booleans
)

select * from customer_order_count
```

**PR #1 Change** (add incremental config and channel filter):
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
    where channel in ('google_hotel_ads', 'kayak', 'trivago')
    {% if is_incremental() %}
        and ordered_at > (select max(ordered_at) from {{ this }})
    {% endif %}
),

order_items as (
    select * from {{ ref('order_items') }}
),

order_items_summary as (
    select
        order_id,
        sum(supply_cost) as order_cost,
        sum(product_price) as order_items_subtotal,
        count(order_item_id) as count_order_items,
        sum(
            case
                when is_food_item then 1
                else 0
            end
        ) as count_food_items,
        sum(
            case
                when is_drink_item then 1
                else 0
            end
        ) as count_drink_items
    from order_items
    group by 1
),

compute_booleans as (
    select
        orders.*,
        order_items_summary.order_cost,
        order_items_summary.order_items_subtotal,
        order_items_summary.count_food_items,
        order_items_summary.count_drink_items,
        order_items_summary.count_order_items,
        order_items_summary.count_food_items > 0 as is_food_order,
        order_items_summary.count_drink_items > 0 as is_drink_order
    from orders
    left join
        order_items_summary
        on orders.order_id = order_items_summary.order_id
),

customer_order_count as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by ordered_at asc
        ) as customer_order_number
    from compute_booleans
)

select * from customer_order_count
```

### Expected Recce Output for PR #1

**Value Diff**:
- Row count: May increase (if channel simulation adds data)
- New columns: `channel` with values ['google_hotel_ads', 'kayak', 'trivago']
- Aggregates: Order totals may change

**Profile Diff**:
- `channel`: New categorical values
- Distribution: 50% Google, 30% Kayak, 20% Trivago

**Incremental Validation**:
- ✅ Unique key: `order_id` prevents duplicates
- ✅ Incremental strategy: Time-based on `ordered_at`
- ✅ Schema change: `append_new_columns` handles new fields

---

## PR #2: Model Rename (Breaking Change)

### Change: Rename Staging Orders Model

**Action**: Rename file
```bash
mv jaffle-shop/models/staging/stg_orders.sql \
   jaffle-shop/models/staging/staging_orders.sql
```

**File**: `jaffle-shop/models/staging/staging_orders.sql`

**Content** (same as baseline, just renamed):
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

        ---------- channel
        'google_hotel_ads' as channel

    from source
)

select * from renamed
```

**IMPORTANT**: Do NOT update `jaffle-shop/models/marts/orders.sql` - leave it with:
```sql
orders as (
    select * from {{ ref('stg_orders') }}  -- ❌ This will break!
),
```

### Expected Recce Output for PR #2

**Breaking Changes**:
- ❌ Model deleted: `stg_orders`
- ✅ Model added: `staging_orders`
- ❌ Downstream broken: `orders` model references `stg_orders` (not found)

**Dependency Graph**:
```
staging_orders (new)
    ↓
orders (marts) ──→ ❌ Broken reference to stg_orders
    ↓
customers (marts) ──→ ❌ Will fail (depends on orders)
```

**Compilation Error**:
```
Compilation Error
  In model orders (models/marts/orders.sql)
    'stg_orders' is undefined
```

### Fix for PR #2 (After Training)

Update `jaffle-shop/models/marts/orders.sql`:
```sql
orders as (
    select * from {{ ref('staging_orders') }}  -- ✅ Fixed!
),
```

---

## PR #3: Timestamp Timezone Conversion

### Change: Convert EST to UTC in Staging

**File**: `jaffle-shop/models/staging/stg_orders.sql`

**Baseline**:
```sql
{{ dbt.date_trunc('day','ordered_at') }} as ordered_at,
```

**PR #3 Change** (EST to UTC conversion):
```sql
-- PR #3: Convert from EST to UTC (EST is UTC-5, so add 5 hours)
-- DuckDB syntax: use interval arithmetic
date_trunc('day', ordered_at + interval '5 hours') as ordered_at,
```

**Full file** (PR #3 version):
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

        ---------- timestamps (PR #3: EST to UTC conversion)
        -- EST is UTC-5, so add 5 hours to convert to UTC
        date_trunc('day', ordered_at + interval '5 hours') as ordered_at,

        ---------- channel
        'google_hotel_ads' as channel

    from source
)

select * from renamed
```

### Expected Recce Output for PR #3

**Value Diff**:
- All `ordered_at` timestamps shift by +5 hours
- Example: `2024-01-15 19:00 EST` → `2024-01-16 00:00 UTC`
- Date boundaries may change (orders move to next day)

**Profile Diff**:
- Min timestamp: +5 hours
- Max timestamp: +5 hours
- Date distribution: Some dates may have different row counts
- Example: Orders at 11 PM EST move to next day in UTC

**Uniqueness Validation**:
- ✅ `order_id` still unique (no duplicates)
- ✅ Primary keys preserved
- ✅ Foreign key relationships intact

**Downstream Impact**:
- `orders` model: Uses `ordered_at` for ordering
- `customers` model: Uses `first_ordered_at`, `last_ordered_at` (will shift)
- Date-based aggregations: May show different daily totals

### Example Value Shift

**Before** (EST):
```
order_id | ordered_at
---------|------------
1        | 2024-01-15 19:00:00
2        | 2024-01-15 23:00:00
3        | 2024-01-16 01:00:00
```

**After** (UTC):
```
order_id | ordered_at
---------|------------
1        | 2024-01-16 00:00:00  (+5 hours)
2        | 2024-01-16 04:00:00  (+5 hours, moved to next day)
3        | 2024-01-16 06:00:00  (+5 hours)
```

**Impact**: Order #2 moves from Jan 15 to Jan 16, affecting daily aggregations.

---

## Summary Table

| PR | File Changed | Change Type | Recce Focus |
|----|--------------|-------------|-------------|
| #1 | `stg_orders.sql` | Add channel simulation | Profile Diff (new values) |
| #1 | `orders.sql` | Incremental + filter | Value Diff, Incremental Logic |
| #2 | `stg_orders.sql` → `staging_orders.sql` | Rename file | Breaking Changes |
| #2 | `orders.sql` | (Not updated - intentional) | Dependency Graph |
| #3 | `stg_orders.sql` | Timestamp conversion | Value Diff, Profile Diff |

---

## Testing Commands

### PR #1
```bash
git checkout pr1-channel-expansion
dbt build
recce run
```

### PR #2
```bash
git checkout pr2-model-rename
dbt compile  # Will fail - that's expected
recce run    # Shows breaking changes
```

### PR #3
```bash
git checkout pr3-timestamp-timezone
dbt build
recce run
```

---

**Ready to implement?** Use these exact changes in your PR branches.

