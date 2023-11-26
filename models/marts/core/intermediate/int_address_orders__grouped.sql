WITH stg_orders AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

int_address_orders__grouped AS (
    SELECT order_address_id,
            -- order dates
            cast(min(order_created_at_utc) as date) AS oldest_order_date,
            cast(max(order_created_at_utc) as date) AS most_recent_order_date,
            -- order cost aggregations
            min(order_cost_in_usd) AS cheapest_order_cost_in_usd,
            max(order_cost_in_usd) AS most_expensive_order_cost_in_usd,
            cast(avg(order_cost_in_usd) as number(38,2)) AS average_order_cost_in_usd,
            sum(order_cost_in_usd) AS total_amount_spent_in_usd,
            -- number of total orders
            cast(count(order_address_id) as number(38,0)) AS number_of_total_orders,
            -- address_value = average_order_cost_in_usd * number_of_total_orders
            cast((avg(order_cost_in_usd) *  count(order_address_id)) as number(38,2)) AS address_value_in_usd
    FROM stg_orders
    GROUP BY order_address_id
    )

SELECT * FROM int_address_orders__grouped