SELECT
    order_id,
    product_id,
    valor_liquido
FROM {{ ref('ft_vendas') }}
WHERE valor_liquido <= 0