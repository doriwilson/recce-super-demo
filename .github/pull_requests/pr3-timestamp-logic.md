# PR #3: UTC Date Conversion

**Branch**: `pr3-timestamp-logic`  
**Business Scenario**: Validating date conversion from EST to UTC  
**Training Focus**: Value Diff and Profile Diff for date conversion validation

## What This PR Demonstrates

This PR simulates a timezone conversion scenario: you're standardizing dates from EST to UTC across your models. This is critical when extending to new channels that might use different timezones.

### The Change

We're modifying `stg_orders` to convert `order_date` from EST to UTC. This simulates:
- Converting dates from EST timezone to UTC
- Ensuring consistency across channels (Google, Kayak, Trivago)
- Validating that date-based aggregations and keys aren't broken

**Before**: `order_date` as-is (assumed EST)  
**After**: `order_date` converted to UTC date (EST midnight + 5 hours = UTC date)

### Why This Matters

Timestamp changes can have subtle but critical impacts:
- **Uniqueness**: If timestamps are part of composite keys, timezone changes can break uniqueness
- **Incremental Logic**: Date-based incremental models might miss or duplicate data
- **Aggregations**: Date-based aggregations (daily, weekly) can shift
- **Downstream Dependencies**: Any model using dates for joins or filters might break

## Expected Recce Findings

When you run `recce run` comparing this PR to main, you should see:

### 1. Value Diff
- **Date Values**: Some `order_date` values may shift to the next day (EST → UTC conversion)
- **Row Count**: Should remain the same (25 rows)
- **Action**: Verify the UTC date conversion is correct

### 2. Profile Diff
- **order_date Column**:
  - Min/max dates may shift if dates cross day boundaries
  - Distribution might change if dates shift to next day
  - Null percentage should remain 0%
- **Action**: Confirm dates that cross midnight are handled correctly

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
   - Added UTC date conversion logic
   - Converts `order_date` from EST to UTC date
   - Treats date as EST midnight, adds 5 hours, extracts UTC date

## Validation Checklist

Use this checklist when reviewing this PR:

- [ ] **Date Shift Verification**: Dates converted from EST to UTC (may shift to next day)
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
dbt build --target dev

# 3. Run Recce comparison
recce server recce_state.json

# 4. Review findings
# - Check Value Diff: Dates converted to UTC (may shift to next day)
# - Check Profile Diff: Date min/max may shift
# - Verify row counts unchanged
# - Check downstream date aggregations

# 5. Validate UTC conversion (optional but recommended)
# Run the custom validation query to verify date shifts are only from UTC conversion
dbt compile --select validate_utc_date_conversion
# Then run the compiled SQL in DuckDB or Recce UI
```

## Automatic UTC Date Validation (Preset Check)

Recce includes a **preset check** in `recce.yml` that automatically validates date columns in `customer_orders` whenever the model or its upstream dependencies change:

**Preset Check: "Customer Orders UTC Date Validation"**
- **Type**: `query` (custom SQL)
- **Model**: `customer_orders`
- **Primary Key**: `customer_id`
- **Focus**: `first_order_date` and `last_order_date` columns
- **Triggers**: Automatically runs when:
  - `customer_orders` model is modified
  - Upstream models change (e.g., `stg_orders`, `orders`)

**How it works:**
1. When you run `recce server recce_state.json`, this check runs automatically
2. Recce executes the SQL query in both base (prod) and target (dev) environments
3. Compares `first_order_date` and `last_order_date` values between environments
4. Shows query diff results in the Recce UI
5. **You validate**: Check that date shifts are only 0 or +1 day (expected from EST→UTC conversion)

**To view results:**
- Open Recce server: `recce server recce_state.json`
- Navigate to "Preset Checks" → "Customer Orders UTC Date Validation"
- Review the query diff - compare `first_order_date` and `last_order_date` between base and target
- **Validate**: Ensure all date shifts are 0 or +1 day (no backward shifts, no shifts >1 day)

## Custom SQL Validation Query (Advanced)

For additional validation logic (ensuring dates only shift 0 or +1 day), we've included a custom SQL query (`analyses/validate_utc_date_conversion.sql`):

**What it checks:**
- ✅ Dates only shift forward by 0 or 1 day (never backward)
- ✅ No dates shift by more than 1 day
- ✅ Order counts match between prod and dev
- ✅ All shifts are consistent with EST→UTC conversion logic

**How to run:**
```bash
# Compile the query
dbt compile --select validate_utc_date_conversion

# The compiled SQL is in target/compiled/super_recce_training/analyses/
# Run it in DuckDB or copy into Recce's SQL query interface
```

See [analyses/README.md](../../analyses/README.md) for detailed instructions.

**Note**: The preset check provides automatic comparison, while the custom SQL query adds validation logic to ensure shifts are within expected bounds.

## Real-World Application

In your actual project, this pattern applies when:
- Standardizing timezones across channels (Google EST → All UTC)
- Converting timestamps when adding new channels (Kayak, Trivago)
- Fixing timezone bugs in existing models
- Migrating from local time to UTC

**Key Takeaway**: Always validate date/timezone conversions with Recce's Value Diff and Profile Diff. UTC conversions can have subtle downstream effects, especially when dates cross day boundaries.

## Technical Details

The UTC date conversion in this PR:
- Assumes source dates are in EST timezone
- Converts to UTC by treating date as EST midnight, adding 5 hours, then extracting the date
- Uses DuckDB's `timestamp` and `date` functions
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
- ✅ UTC date conversion validation

Apply these patterns to your real dbt project when extending to Kayak and Trivago channels!

