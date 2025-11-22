-- staging_orders.sql
-- Staging model for order data
-- 
-- PR #2 CHANGES:
-- - Model renamed from stg_orders to staging_orders
-- - This is a refactoring to improve naming consistency
--
-- IMPORTANT: This PR intentionally does NOT update the ref() in models/marts/orders.sql
-- This creates a breaking change that Recce should catch.
--
-- In your real project, this simulates refactoring staging layer for new channels.

with source as (
    select * from {{ source('jaffle_shop', 'jaffle_shop_orders') }}
),

renamed as (
    select
        id as order_id,
        user_id as customer_id,
        order_date,  -- <-- PR #3 will convert this to UTC
        status
    from source
)

select * from renamed

