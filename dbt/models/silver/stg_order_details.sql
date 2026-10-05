{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_order_details') }}
),

cleaned AS (
    SELECT
        order_id::INTEGER AS order_id,
        product_id::INTEGER AS product_id,
        unit_price::NUMERIC(10,2) AS unit_price,
        quantity::INTEGER AS quantity,
        discount::NUMERIC(5,2) AS discount
    FROM source
)

SELECT * FROM cleaned