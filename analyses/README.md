# Custom SQL Analysis Queries

This directory contains custom SQL queries for validating specific scenarios in the training repository.

## validate_utc_date_conversion.sql

**Purpose**: Validates that date shifts in `customer_orders` are ONLY from the EST→UTC timezone conversion and not from any other data quality issues.

**When to use**: Run this query when reviewing PR #3 to verify the UTC date conversion is working correctly.

### How to Run

**Option 1: Using dbt compile + DuckDB**
```bash
# Compile the query
dbt compile --select validate_utc_date_conversion

# Run the compiled SQL in DuckDB
# The compiled SQL will be in target/compiled/super_recce_training/analyses/validate_utc_date_conversion.sql
```

**Option 2: Direct SQL in Recce UI**
1. Open Recce server: `recce server recce_state.json`
2. Navigate to the "Query" or "SQL" tab
3. Copy and paste the SQL from this file
4. Replace `prod.customer_orders` and `dev.customer_orders` with the actual schema references if needed

**Option 3: Direct DuckDB Query**
```bash
# Connect to DuckDB and run the query
duckdb super_training.duckdb < analyses/validate_utc_date_conversion.sql
```

### What It Validates

1. **Date Shift Direction**: 
   - For EST→UTC (UTC-5): Dates shift forward (0 or +1 day), never backward
   - For UTC+ timezones (JST, AEST, etc.): Dates can shift backward (0 or -1 day)
2. **Date Shift Magnitude**: Dates should never shift by more than 1 day in either direction
3. **Row Count Consistency**: Order counts should match between prod and dev
4. **Expected Behavior**: 
   - **EST→UTC**: Dates that cross UTC midnight when adding 5 hours shift by +1 day
   - **UTC+ timezones**: Dates that cross UTC midnight when subtracting hours shift by -1 day
   - Dates that don't cross UTC midnight: No shift (0 days)

### Expected Results

- ✅ **PASSED**: All date shifts are within expected range (0 or ±1 day), order counts match
- ⚠️ **WARNING**: Backward shifts detected (expected for UTC+ timezones, unexpected for EST→UTC)
- ❌ **FAILED**: Shifts >1 day in either direction, or order count mismatches

**Note**: This validation is configured for EST→UTC conversion. For timezones ahead of UTC (UTC+), backward shifts of -1 day are expected and normal.

### Understanding the Output

- `first_order_date_shift`: Number of days the first order date shifted (should be 0 or 1)
- `last_order_date_shift`: Number of days the last order date shifted (should be 0 or 1)
- `validation_status`: Overall validation result (✅ PASSED or ❌ FAILED)

If you see ❌ FAILED, investigate:
- Are there dates shifting backward? (indicates a logic error)
- Are there dates shifting by more than 1 day? (indicates unexpected behavior)
- Are order counts different? (indicates data loss or duplication)

