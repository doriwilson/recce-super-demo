-- stg_customers.sql
-- Staging model for customer data
-- This is a simple pass-through that will be referenced by downstream models

with source as (
    select * from {{ source('jaffle_shop', 'jaffle_shop_customers') }}
),

renamed as (
    select
        id as customer_id,
        first_name,
        last_name
    from source
)

select * from renamed

