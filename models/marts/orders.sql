-- orders.sql
-- Final mart model: enriched orders with customer and payment data
--
-- BASE VERSION (main branch):
-- - All orders included (no filter)
-- - Materialized as table
--
-- PR #1 will convert this to incremental and add status filter

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

