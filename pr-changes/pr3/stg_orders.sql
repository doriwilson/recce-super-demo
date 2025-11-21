-- stg_orders.sql
-- Staging model for order data
-- 
-- PR #3 CHANGES:
-- - Added timezone conversion: EST to UTC
-- - Converts order_date by adding 5 hours (EST is UTC-5)
-- - This simulates standardizing timestamps across channels
--
-- IMPORTANT FOR TRAINING:
-- - This demonstrates how Recce validates timestamp logic changes
-- - Watch for impacts on uniqueness, downstream aggregations, and date boundaries
--
-- In your real project, this would handle timezone standardization when adding
-- new channels (Kayak, Trivago) that might use different timezones.

with source as (
    select * from {{ source('jaffle_shop', 'jaffle_shop_orders') }}
),

renamed as (
    select
        id as order_id,
        user_id as customer_id,
        -- PR #3: Convert order_date from EST to UTC
        -- EST is UTC-5, so we add 5 hours
        -- In production, you'd use your warehouse's timezone functions
        -- (e.g., Snowflake's CONVERT_TIMEZONE)
        order_date + interval '5 hours' as order_date,
        status
    from source
)

select * from renamed

