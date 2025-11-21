-- orders.sql
-- Final mart model: enriched orders with customer and payment data
--
-- IMPORTANT FOR TRAINING:
-- - PR #1 will convert this to an incremental model with filter changes
-- - PR #2 will break this model by not updating the ref() after renaming stg_orders
--
-- This model represents your final business-facing table.
-- In your real project, this would be your channel-agnostic orders table.

with orders as (
    select * from {{ ref('stg_orders') }}  -- <-- PR #2 will break this ref
),

customers as (
    select * from {{ ref('stg_customers') }}
),

payments as (
    select * from {{ ref('int_order_payments') }}
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        customers.first_name,
        customers.last_name,
        orders.order_date,
        orders.status,
        payments.total_amount as amount
    from orders
    left join customers on orders.customer_id = customers.customer_id
    left join payments on orders.order_id = payments.order_id
    -- PR #1 will add a filter here: where status in ('completed', 'shipped')
)

select * from final

