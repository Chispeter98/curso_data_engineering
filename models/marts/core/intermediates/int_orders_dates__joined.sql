{{
    config(
        materialized='incremental'
        unique_key='order_id'
    )
}}

WITH stg_orders AS (
    SELECT
        order_id,
        customer_id,
        address_id,
        promotion_id,
        tracking_id,
        cast(created_at_utc as date)              AS creation_date,
        cast(created_at_utc as time)              AS creation_time,
        cast(estimated_delivery_at_utc as date)   AS estimated_delivery_date,
        cast(estimated_delivery_at_utc as time)   AS estimated_delivery_time,
        cast(delivered_at_utc as date)            AS delivery_date,
        cast(delivered_at_utc as time)            AS delivery_time,
        shipping_service_name,
        shipping_service_cost_in_usd,
        order_cost_in_usd,
        order_total_cost_in_usd,
        order_status,
        batched_at_utc
    FROM {{ ref('stg_sql_server_dbo__orders') }}
    {% if is_incremental() %}
        WHERE batched_at_utc > (SELECT max(batched_at_utc) FROM {{ this }})
    {% endif %}
),

stg_dates AS (
    SELECT
        date_id,
        date_day
    FROM {{ ref('stg_staging__dates') }}
),

int_orders_dates__joined AS (
    SELECT
        o.order_id                          AS order_id,
        o.customer_id                       AS customer_id,
        o.address_id                        AS address_id,
        o.promotion_id                      AS promotion_id,
        o.tracking_id                       AS tracking_id,
        d1.date_id                          AS creation_date_id,
        d2.date_id                          AS estimated_delivery_date_id,
        d3.date_id                          AS delivery_date_id,
        o.creation_time                     AS creation_time,
        o.estimated_delivery_time           AS estimated_delivery_time,
        o.delivery_time                     AS delivery_time,
        o.shipping_service_name             AS shipping_service_name,
        o.shipping_service_cost_in_usd      AS shipping_service_cost_in_usd,
        o.order_cost_in_usd                 AS order_cost_in_usd,
        o.order_total_cost_in_usd           AS order_total_cost_in_usd,
        o.order_status                      AS order_status,
        o.batched_at_utc                    AS batched_at_utc
    FROM stg_orders AS o
    LEFT JOIN stg_dates AS d1 ON o.creation_date = d1.date_day
    LEFT JOIN stg_dates AS d2 ON o.estimated_delivery_date = d2.date_day
    LEFT JOIN stg_dates AS d3 ON o.delivery_date = d3.date_day
)

SELECT * FROM int_orders_dates__joined