# PR #3: Timestamp Field Logic Change

**Branch**: `pr3-timestamp-logic`  
**Business Scenario**: Validating timestamp logic changes (EST → UTC conversion)  
**Training Focus**: Value Diff and Profile Diff for timestamp validation

## What This PR Demonstrates

This PR simulates a timezone conversion scenario: you're standardizing timestamps from EST to UTC across your models. This is critical when extending to new channels that might use different timezones.

### The Change

We're modifying `stg_orders` to convert `order_date` from EST to UTC. This simulates:
- Converting timezone-aware timestamps
- Ensuring consistency across channels (Google, Kayak, Trivago)
- Validating that uniqueness and surrogate keys aren't broken

**Before**: `order_date` as-is (assumed EST)  
**After**: `order_date` converted to UTC (adds 5 hours for EST → UTC)

### Why This Matters

Timestamp changes can have subtle but critical impacts:
- **Uniqueness**: If timestamps are part of composite keys, timezone changes can break uniqueness
- **Incremental Logic**: Date-based incremental models might miss or duplicate data
- **Aggregations**: Date-based aggregations (daily, weekly) can shift
- **Downstream Dependencies**: Any model using dates for joins or filters might break

## Expected Recce Findings

When you run `recce run` comparing this PR to main, you should see:

### 1. Value Diff
- **Date Values**: All `order_date` values should shift by +5 hours (EST → UTC)
- **Row Count**: Should remain the same (25 rows)
- **Action**: Verify the timezone conversion is correct

### 2. Profile Diff
- **order_date Column**:
  - Min/max values will shift
  - Distribution might change if dates cross day boundaries
  - Null percentage should remain 0%
- **Action**: Confirm the shift is exactly 5 hours and no dates are lost

### 3. Downstream Impact
- **customer_orders Model**:
  - `first_order_date` and `last_order_date` might change
  - Daily aggregations might shift if dates cross boundaries
- **Action**: Verify downstream date-based logic still works

### 4. Uniqueness Validation
- If `order_date` is part of a composite key, verify uniqueness is maintained
- Check for any duplicate rows introduced

## Files Changed

1. **`models/staging/stg_orders.sql`**
   - Added timezone conversion logic
   - Converts `order_date` from EST to UTC
   - Uses DuckDB's timezone functions

## Validation Checklist

Use this checklist when reviewing this PR:

- [ ] **Date Shift Verification**: All dates shifted by exactly 5 hours (EST → UTC)
- [ ] **Row Count Unchanged**: Still 25 rows (no data loss)
- [ ] **Uniqueness Maintained**: No duplicate rows introduced
- [ ] **Downstream Impact**: Check `customer_orders.first_order_date` and `last_order_date`
- [ ] **Date Boundaries**: Verify dates that cross day boundaries are handled correctly
- [ ] **Profile Diff Review**: Min/max dates shifted appropriately
- [ ] **No Breaking Changes**: All downstream models still build

## How to Test This PR

```bash
# 1. Switch to PR branch
git checkout pr3-timestamp-logic

# 2. Rebuild models
dbt build

# 3. Run Recce comparison
recce run

# 4. Review findings
# - Check Value Diff: All dates should shift +5 hours
# - Check Profile Diff: Date min/max should shift
# - Verify row counts unchanged
# - Check downstream date aggregations
```

## Real-World Application

In your actual project, this pattern applies when:
- Standardizing timezones across channels (Google EST → All UTC)
- Converting timestamps when adding new channels (Kayak, Trivago)
- Fixing timezone bugs in existing models
- Migrating from local time to UTC

**Key Takeaway**: Always validate timestamp changes with Recce's Value Diff and Profile Diff. Timezone conversions can have subtle downstream effects that aren't immediately obvious.

## Technical Details

The timezone conversion in this PR:
- Assumes source data is in EST (UTC-5)
- Converts to UTC by adding 5 hours
- Uses DuckDB's `timestamp` functions
- In production, you'd use your warehouse's timezone functions (e.g., Snowflake's `CONVERT_TIMEZONE`)

## Edge Cases to Consider

When applying this to your real models, watch for:
- **DST Transitions**: EST/EDT changes (UTC-5 vs UTC-4)
- **Date Boundaries**: Dates that cross midnight when converted
- **Null Handling**: Ensure null timestamps are handled correctly
- **Composite Keys**: If timestamps are part of keys, verify uniqueness

## Next Steps

After reviewing this PR:
1. Understand how Recce validates timestamp changes
2. Review Value Diff for date shifts
3. Review Profile Diff for distribution changes
4. Apply these patterns to your real channel extension work

---

**Congratulations!** You've completed all three PR scenarios. You now understand:
- ✅ Incremental model validation
- ✅ Breaking change detection
- ✅ Timestamp/timezone validation

Apply these patterns to your real dbt project when extending to Kayak and Trivago channels!

