-- stg_orders.sql
-- Staging model for order data
-- 
-- PR #3 CHANGES:
-- - Convert order_date from JST (Japan Standard Time, UTC+9) to UTC date
-- - JST is ahead of UTC, so dates shift backward (e.g., Jan 2 2AM JST = Jan 1 5PM UTC)
-- - This simulates timezone standardization across channels and creates visible date shifts
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
        -- PR #3: Convert order_date from JST (Japan Standard Time, UTC+9) to UTC date
        -- JST is ahead of UTC, so dates can shift backward when converting to UTC
        -- This creates visible date shifts for training purposes
        -- Convert DATE to TIMESTAMP at JST timezone, then to UTC, then extract date
        date((order_date::TIMESTAMP AT TIME ZONE 'Asia/Tokyo') AT TIME ZONE 'UTC') as order_date,
        status
    from source
)

select * from renamed

