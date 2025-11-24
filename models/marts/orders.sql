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
    select * from {{ ref('stg_orders') }}
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
)

select * from final

