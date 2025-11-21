
  
  create view "super_training"."prod"."stg_customers__dbt_tmp" as (
    -- stg_customers.sql
-- Staging model for customer data
-- This is a simple pass-through that will be referenced by downstream models

with source as (
    select * from "super_training"."dev"."jaffle_shop_customers"
),

renamed as (
    select
        id as customer_id,
        first_name,
        last_name
    from source
)

select * from renamed
  );
