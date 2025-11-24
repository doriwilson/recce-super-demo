-- stg_orders.sql
-- Staging model for order data
-- 
-- IMPORTANT FOR TRAINING:
-- - PR #2 will rename this model to staging_orders (breaking change demo)
-- - PR #3 will modify the timestamp logic here (EST → UTC conversion demo)
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
        order_date,  -- <-- PR #3 will convert this from JST to UTC
        status
    from source
)

select * from renamed

