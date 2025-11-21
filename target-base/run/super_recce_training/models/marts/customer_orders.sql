
  
    
    

    create  table
      "super_training"."dev"."customer_orders__dbt_tmp"
  
    as (
      -- customer_orders.sql
-- Final mart model: customer-level order aggregations
-- This demonstrates downstream dependencies on the orders model

with orders as (
    select * from "super_training"."dev"."orders"
),

aggregated as (
    select
        customer_id,
        first_name,
        last_name,
        count(*) as order_count,
        sum(amount) as total_spent,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from orders
    group by customer_id, first_name, last_name
)

select * from aggregated
    );
  
  