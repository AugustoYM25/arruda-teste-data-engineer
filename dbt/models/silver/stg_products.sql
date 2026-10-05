{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_products') }}
),

cleaned AS (
    SELECT
        product_id::INTEGER AS product_id,
        TRIM(product_name)::VARCHAR(150) AS product_name,
        
        supplier_id::INTEGER AS supplier_id,
        category_id::INTEGER AS category_id,
        
        TRIM(quantity_per_unit)::VARCHAR(50) AS quantity_per_unit,
        
        unit_price::NUMERIC(10,2) AS unit_price,
        
        units_in_stock::INTEGER AS units_in_stock,
        units_on_order::INTEGER AS units_on_order,
        reorder_level::INTEGER AS reorder_level,
        
        discontinued::INTEGER AS discontinued
    FROM source
)

SELECT * FROM cleaned