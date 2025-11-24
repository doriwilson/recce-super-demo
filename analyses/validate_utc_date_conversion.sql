-- validate_utc_date_conversion.sql
-- Custom SQL query to verify UTC date conversion in customer_orders
-- 
-- This query validates that any date shifts are ONLY from the timezone→UTC conversion
-- and not from any other data quality issues or logic errors.
--
-- Expected behavior (for EST→UTC conversion, UTC-5):
-- - Dates should only shift forward by 0 or 1 day (never backward)
-- - Date shifts occur when EST midnight + 5 hours crosses UTC midnight
-- - No dates should shift by more than 1 day
--
-- Note: For timezones AHEAD of UTC (UTC+), dates can shift backward:
-- - JST (UTC+9): Dates can shift backward by 1 day
-- - AEST (UTC+10): Dates can shift backward by 1 day
-- - This validation is configured for EST→UTC (backward shifts = unexpected)
--
-- Row counts should remain the same regardless of timezone

with prod_data as (
    select
        customer_id,
        first_name,
        last_name,
        order_count,
        total_spent,
        first_order_date,
        last_order_date
    from prod.customer_orders
),

dev_data as (
    select
        customer_id,
        first_name,
        last_name,
        order_count,
        total_spent,
        first_order_date,
        last_order_date
    from dev.customer_orders
),

comparison as (
    select
        coalesce(p.customer_id, d.customer_id) as customer_id,
        coalesce(p.first_name, d.first_name) as first_name,
        coalesce(p.last_name, d.last_name) as last_name,
        
        -- Prod values
        p.first_order_date as prod_first_order_date,
        p.last_order_date as prod_last_order_date,
        
        -- Dev values (with UTC conversion)
        d.first_order_date as dev_first_order_date,
        d.last_order_date as dev_last_order_date,
        
        -- Calculate date differences (DuckDB syntax)
        datediff('day', p.first_order_date, d.first_order_date) as first_order_date_shift,
        datediff('day', p.last_order_date, d.last_order_date) as last_order_date_shift,
        
        -- Verify expected UTC conversion logic
        -- For EST→UTC (UTC-5): Dates shift forward by 0 or 1 day
        -- For timezones ahead of UTC (UTC+): Dates can shift backward by 0 or 1 day
        -- This validation is configured for EST→UTC conversion
        case 
            when datediff('day', p.first_order_date, d.first_order_date) = 0 then 'No shift (expected)'
            when datediff('day', p.first_order_date, d.first_order_date) = 1 then 'Shifted +1 day (EST→UTC crosses midnight)'
            when datediff('day', p.first_order_date, d.first_order_date) = -1 then 'Shifted -1 day (UTC+ timezone→UTC, expected for JST/AEST/etc)'
            when datediff('day', p.first_order_date, d.first_order_date) < -1 then '❌ UNEXPECTED: Shifted backward by more than 1 day!'
            when datediff('day', p.first_order_date, d.first_order_date) > 1 then '❌ UNEXPECTED: Shifted forward by more than 1 day!'
            else '❌ UNEXPECTED: Unexpected shift pattern!'
        end as first_order_validation,
        
        case 
            when datediff('day', p.last_order_date, d.last_order_date) = 0 then 'No shift (expected)'
            when datediff('day', p.last_order_date, d.last_order_date) = 1 then 'Shifted +1 day (EST→UTC crosses midnight)'
            when datediff('day', p.last_order_date, d.last_order_date) = -1 then 'Shifted -1 day (UTC+ timezone→UTC, expected for JST/AEST/etc)'
            when datediff('day', p.last_order_date, d.last_order_date) < -1 then '❌ UNEXPECTED: Shifted backward by more than 1 day!'
            when datediff('day', p.last_order_date, d.last_order_date) > 1 then '❌ UNEXPECTED: Shifted forward by more than 1 day!'
            else '❌ UNEXPECTED: Unexpected shift pattern!'
        end as last_order_validation,
        
        -- Check if row counts match (should be same)
        p.order_count as prod_order_count,
        d.order_count as dev_order_count,
        p.order_count = d.order_count as order_count_matches
        
    from prod_data p
    full outer join dev_data d
        on p.customer_id = d.customer_id
)

select
    customer_id,
    first_name || ' ' || last_name as customer_name,
    
    -- Show the date shifts
    prod_first_order_date,
    dev_first_order_date,
    first_order_date_shift,
    first_order_validation,
    
    prod_last_order_date,
    dev_last_order_date,
    last_order_date_shift,
    last_order_validation,
    
    -- Validation flags
    order_count_matches,
    
        -- Overall validation
        -- For EST→UTC: Only allow 0 or +1 day shifts
        -- For UTC+ timezones: Would allow 0 or -1 day shifts (update this logic if needed)
        case
            when first_order_validation like '❌%' or last_order_validation like '❌%' then '❌ FAILED'
            when not order_count_matches then '❌ FAILED: Order count mismatch'
            -- For EST→UTC: Flag backward shifts as unexpected
            when first_order_date_shift < 0 or last_order_date_shift < 0 then '⚠️ WARNING: Backward shift detected (expected for UTC+ timezones, unexpected for EST→UTC)'
            else '✅ PASSED'
        end as validation_status

from comparison

order by 
    validation_status desc,  -- Show failures first
    abs(first_order_date_shift) desc,  -- Then by largest shifts
    customer_id

