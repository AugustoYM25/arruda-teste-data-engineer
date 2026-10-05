{{ config(materialized='table') }}

WITH ordens AS (
    SELECT
        order_id,
        customer_id,
        order_date AS data_pedido
    FROM {{ ref('stg_orders') }}
),

detalhes AS (
    SELECT
        order_id,
        product_id,
        quantity,
        unit_price,
        discount
    FROM {{ ref('stg_order_details') }}
)

SELECT
    -- Chaves de relacionamento (Star Schema)
    o.customer_id,
    d.product_id,
    o.data_pedido, 
    d.order_id,
    
    -- Métricas operacionais
    d.quantity AS quantidade,
    d.unit_price AS preco_unitario,
    d.discount AS desconto,
    
    -- Cálculos de regras de negócio
    (d.quantity * d.unit_price)::NUMERIC(12,2) AS valor_bruto,
    ((d.quantity * d.unit_price) * (1 - d.discount))::NUMERIC(12,2) AS valor_liquido

FROM detalhes d
INNER JOIN ordens o ON d.order_id = o.order_id