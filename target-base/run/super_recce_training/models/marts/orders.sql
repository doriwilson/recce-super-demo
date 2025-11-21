
        
            delete from "super_training"."dev"."orders"
            where (
                order_id) in (
                select (order_id)
                from "orders__dbt_tmp20251121141813480712"
            );

        
    

    insert into "super_training"."dev"."orders" ("order_id", "customer_id", "first_name", "last_name", "order_date", "status", "amount")
    (
        select "order_id", "customer_id", "first_name", "last_name", "order_date", "status", "amount"
        from "orders__dbt_tmp20251121141813480712"
    )
  