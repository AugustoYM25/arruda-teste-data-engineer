{{ config(materialized='table') }}

WITH limites AS (
    SELECT
        MIN(order_date)::DATE AS data_inicial,
        MAX(order_date)::DATE AS data_final
    FROM {{ ref('stg_orders') }}
),

calendario AS (
    SELECT
        generate_series(
            data_inicial,
            data_final,
            INTERVAL '1 day'
        )::DATE AS data
    FROM limites
)

SELECT
    data,
    EXTRACT(YEAR FROM data)::INTEGER AS ano,
    EXTRACT(QUARTER FROM data)::INTEGER AS trimestre,
    EXTRACT(MONTH FROM data)::INTEGER AS mes,

    CASE EXTRACT(MONTH FROM data)
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS nome_mes,

    EXTRACT(ISODOW FROM data)::INTEGER AS dia_da_semana,

    EXTRACT(ISODOW FROM data) IN (6, 7) AS indicador_fim_semana

FROM calendario
