{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_customers') }}
),

cleaned AS (
    SELECT
        TRIM(customer_id)::VARCHAR(5) AS customer_id,
        TRIM(company_name)::VARCHAR(255) AS company_name,
        TRIM(contact_name)::VARCHAR(255) AS contact_name,
        TRIM(contact_title)::VARCHAR(255) AS contact_title,
        TRIM(address)::VARCHAR(255) AS address,
        TRIM(city)::VARCHAR(100) AS city,
        COALESCE(NULLIF(TRIM(region), ''), 'Desconhecido')::VARCHAR(50) AS region,
        TRIM(postal_code)::VARCHAR(20) AS postal_code,
        TRIM(country)::VARCHAR(100) AS country,
        COALESCE(NULLIF(REGEXP_REPLACE(phone, '[^0-9]', '', 'g'), ''), 'Desconhecido')::VARCHAR(50) AS phone,
        COALESCE(NULLIF(REGEXP_REPLACE(fax, '[^0-9]', '', 'g'), ''), 'Desconhecido')::VARCHAR(50) AS fax
    FROM source
)

SELECT * FROM cleaned