WITH stg_customers AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__customers') }}
    ),
    
stg_addresses AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__addresses') }}
),

int_customer_orders__joined AS (
    SELECT *
    FROM {{ ref('int_customer_orders__joined') }}
    ),

dim_customers AS (
    SELECT
        -- CUSTOMER_ADDRESSES?? -> INT
        -- CUSTOMERS
        customers.customer_id AS customer_id,
        customers.customer_first_name AS customer_first_name,
        customers.customer_last_name AS customer_last_name,
        customers.customer_phone_number AS customer_phone_number,
        customers.customer_email AS customer_email,
        -- ADDRESSES
        addresses.address_street_number AS customer_street_number,
        addresses.address_street_name AS customer_street_name,
        addresses.address_state_name AS customer_state_name,
        addresses.address_zipcode AS customer_zipcode,
        addresses.address_country_name AS customer_country_name,
        -- CUSTOMER_ORDER__JOINED
        -- order dates
        customer_orders.oldest_order_date AS oldest_order_date,
        customer_orders.most_recent_order_date AS most_recent_order_date,
        -- order cost aggregations
        customer_orders.cheapest_order_cost_in_usd AS cheapest_order_cost_in_usd,
        customer_orders.most_expensive_order_cost_in_usd AS most_expensive_order_cost_in_usd,
        customer_orders.average_order_cost_in_usd AS average_order_cost_in_usd,
        customer_orders.total_amount_spent_in_usd AS total_amount_spent_in_usd,
        -- number of total orders
        customer_orders.number_of_total_orders AS number_of_total_orders,
        -- customer_value = average_order_cost_in_usd * number_of_orders
        customer_orders.customer_value_in_usd AS customer_value_in_usd
    FROM stg_customers AS customers
    LEFT JOIN stg_addresses AS addresses ON customers.customer_address_id = addresses.address_id
    LEFT JOIN int_customer_orders__joined AS customer_orders ON customers.customer_id = customer_orders.customer_id
    )

SELECT * FROM dim_customers