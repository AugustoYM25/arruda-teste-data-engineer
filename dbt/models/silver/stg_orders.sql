{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_orders') }}
),

cleaned AS (
    SELECT
        -- Chaves e numéricos
        order_id::INTEGER AS order_id,
        TRIM(customer_id)::VARCHAR(5) AS customer_id,
        employee_id::INTEGER AS employee_id,
        
        -- Datas (o ::DATE já limpa os '00:00:00.000' indesejados)
        order_date::DATE AS order_date,
        required_date::DATE AS required_date,
        shipped_date::DATE AS shipped_date,
        
        -- Frete e transportadora
        ship_via::INTEGER AS ship_via,
        freight::NUMERIC(10,2) AS freight,
        
        -- Informações de entrega em texto (mantendo a sua convenção de TRIM)
        TRIM(ship_name)::VARCHAR(100) AS ship_name,
        TRIM(ship_address)::VARCHAR(255) AS ship_address,
        TRIM(ship_city)::VARCHAR(100) AS ship_city,
        
        -- Tratamento de nulos/vazios detectados
        COALESCE(NULLIF(TRIM(ship_region), ''), 'Desconhecido')::VARCHAR(50) AS ship_region,
        COALESCE(NULLIF(TRIM(ship_postal_code), ''), 'Desconhecido')::VARCHAR(20) AS ship_postal_code,
        
        TRIM(ship_country)::VARCHAR(100) AS ship_country
    FROM source
)

SELECT * FROM cleaned