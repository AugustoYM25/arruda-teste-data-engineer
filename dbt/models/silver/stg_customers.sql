{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('bronze', 'raw_customers') }}
),


cleaned AS (
    SELECT
        customer_id::VARCHAR(5) AS customer_id,
        
        INITCAP(unaccent(TRIM(company_name)))::VARCHAR(255) AS company_name,
        INITCAP(unaccent(TRIM(contact_name)))::VARCHAR(255) AS contact_name,
        INITCAP(unaccent(TRIM(contact_title)))::VARCHAR(255) AS contact_title,
        unaccent(TRIM(address))::VARCHAR(255) AS address,
        INITCAP(unaccent(TRIM(city)))::VARCHAR(100) AS city,
        
        COALESCE(UPPER(unaccent(TRIM(region))), 'Desconhecido')::VARCHAR(50) AS region,
        UPPER(TRIM(postal_code))::VARCHAR(20) AS postal_code,
        unaccent(TRIM(country))::VARCHAR(100) AS country,
        
        COALESCE(REGEXP_REPLACE(phone, '\D', '', 'g'), 'Desconhecido')::VARCHAR(50) AS phone_number,
        COALESCE(REGEXP_REPLACE(fax, '\D', '', 'g'), 'Desconhecido')::VARCHAR(50) AS fax_number
    FROM source
)

SELECT * FROM cleaned