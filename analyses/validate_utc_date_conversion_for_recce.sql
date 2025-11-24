-- validate_utc_date_conversion_for_recce.sql
-- Simplified query for Recce preset check
-- This query returns date values that Recce will compare between base and target
-- The validation logic (checking for 0 or +1 day shifts) should be done in the Recce UI
-- by reviewing the query diff results

select
  customer_id,
  first_order_date,
  last_order_date,
  order_count
from {{ ref('customer_orders') }}
order by customer_id

