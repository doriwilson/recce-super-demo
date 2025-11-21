# PR #1: Incremental Model Filter Change

**Branch**: `pr1-incremental-filter`  
**Business Scenario**: Testing incremental model changes safely when expanding channel filters  
**Training Focus**: Incremental model validation with Recce

## What This PR Demonstrates

This PR simulates a common scenario when extending your dbt lineage: you need to modify an incremental model's filter logic. In your real project, this might be expanding from Google Hotel Ads to include Kayak and Trivago channels.

### The Change

We're converting the `orders` model to an incremental materialization and expanding the status filter from `'completed'` to include `'shipped'` orders.

**Before**: All orders (no filter)  
**After**: Only `'completed'` and `'shipped'` orders (incremental model)

### Why This Matters

Incremental models can have subtle bugs:
- Filter changes might exclude historical data incorrectly
- Incremental logic might not capture new data as expected
- Row counts can change unexpectedly
- Downstream aggregations might break

## Expected Recce Findings

When you run `recce run` comparing this PR to main, you should see:

### 1. Value Diff
- **Row Count Change**: The `orders` model will have fewer rows (excluding `'returned'` orders)
- **Expected Change**: ~20% reduction in row count (from 25 to ~20 rows)
- **Action**: Verify this matches your business intent

### 2. Profile Diff
- **Status Column**: Distribution will change (no `'returned'` values)
- **Amount Aggregations**: May change in downstream models
- **Action**: Confirm the new distribution is correct

### 3. Breaking Changes
- **None Expected**: This is a non-breaking change (same columns, same model name)
- **Action**: Verify no downstream models break

### 4. Incremental Logic Validation
- Recce should highlight that this is now an incremental model
- Check that the incremental strategy is correct
- Verify the unique key is appropriate

## Files Changed

1. **`models/marts/orders.sql`**
   - Added `{{ config(materialized='incremental') }}`
   - Added incremental logic with `unique_key: order_id`
   - Added filter: `where status in ('completed', 'shipped')`

## Validation Checklist

Use this checklist when reviewing this PR:

- [ ] **Row Count Change**: Verify the reduction in rows is expected (~20 rows vs 25)
- [ ] **Status Distribution**: Confirm `'returned'` orders are excluded
- [ ] **Downstream Impact**: Check `customer_orders` model still works correctly
- [ ] **Incremental Logic**: Test that incremental builds work:
  ```bash
  dbt run --select orders --full-refresh
  dbt run --select orders  # Should be incremental
  ```
- [ ] **Value Diff Review**: In Recce, verify amount totals are reasonable
- [ ] **No Breaking Changes**: Confirm all downstream models still build

## How to Test This PR

```bash
# 1. Switch to PR branch
git checkout pr1-incremental-filter

# 2. Rebuild models
dbt build

# 3. Run Recce comparison
recce run

# 4. Review findings
# - Check Value Diff for row count changes
# - Check Profile Diff for status distribution
# - Verify no breaking changes
```

## Real-World Application

In your actual project, this pattern applies when:
- Expanding channel filters (Google → Google + Kayak + Trivago)
- Adding new status types to incremental models
- Modifying date range filters in incremental models
- Changing incremental predicates

**Key Takeaway**: Always validate incremental model changes with Recce before merging, as they can have subtle downstream effects.

## Next Steps

After reviewing this PR:
1. Understand how Recce surfaces incremental model changes
2. Review the Value Diff and Profile Diff reports
3. Move to [PR #2](./pr2-model-rename.md) to see breaking change detection

