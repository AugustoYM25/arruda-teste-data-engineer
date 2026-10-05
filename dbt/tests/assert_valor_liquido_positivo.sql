-- Regra de negócio: Nenhuma venda na camada Fato pode ter valor líquido negativo ou zerado.
-- O teste passa se esta consulta retornar zero linhas.

SELECT
    order_id,
    product_id,
    valor_liquido
FROM {{ ref('ft_vendas') }}
WHERE valor_liquido <= 0