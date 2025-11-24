
  
    
    

    create  table
      "super_training"."prod"."int_order_payments__dbt_tmp"
  
    as (
      -- int_order_payments.sql
-- Intermediate model: aggregates payments by order
-- This creates a one-to-one relationship between orders and payment totals

with payments as (
    select * from "super_training"."prod"."stg_payments"
),

aggregated as (
    select
        order_id,
        sum(amount) as total_amount
    from payments
    group by order_id
)

select * from aggregated
    );
  
  