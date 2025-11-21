-- orders.sql
-- Final mart model: enriched orders with customer and payment data
--
-- PR #1 CHANGES:
-- - Converted to incremental materialization
-- - Added status filter: only 'completed' and 'shipped' orders
-- - Added incremental logic with unique_key
--
-- This demonstrates how Recce validates incremental model changes.
-- In your real project, this simulates expanding channel filters.



with orders as (
    select * from "super_training"."prod"."stg_orders"
),

customers as (
    select * from "super_training"."prod"."stg_customers"
),

payments as (
    select * from "super_training"."prod"."int_order_payments"
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
    -- PR #1: Added filter to expand from 'completed' to include 'shipped'
    where orders.status in ('completed', 'shipped')
)

select * from final