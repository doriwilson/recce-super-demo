-- stg_orders.sql
-- Staging model for order data
-- 
-- PR #3 CHANGES:
-- - Convert order_date from EST to UTC date
-- - This simulates timezone standardization across channels
--
-- This model stages raw order data and prepares it for downstream use.
-- In your real project, this would handle channel-specific transformations.

with source as (
    select * from {{ source('jaffle_shop', 'jaffle_shop_orders') }}
),

renamed as (
    select
        id as order_id,
        user_id as customer_id,
        -- PR #3: Convert order_date from EST to UTC date
        -- Treat date as EST midnight, convert to UTC, then extract date
        date(timestamp(order_date) + interval '5 hours') as order_date,
        status
    from source
)

select * from renamed

