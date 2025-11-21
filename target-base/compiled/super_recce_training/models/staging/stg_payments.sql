-- stg_payments.sql
-- Staging model for payment data

with source as (
    select * from "super_training"."dev"."jaffle_shop_payments"
),

renamed as (
    select
        id as payment_id,
        order_id,
        payment_method,
        amount
    from source
)

select * from renamed