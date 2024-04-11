---- top 10 salarios
CREATE OR REPLACE VIEW top_10_rangos_edad_posicion_salario AS
with rangos as (
select  id,
case when edad >= '16' and edad <= '22' then '16-22'
when edad >= '23' and edad <= '25' then '23-25'
when edad >= '26' and edad <= '29' then '26-29'
when edad >= '30'then '30+' end as rango_edad
FROM "catalogos_players"."bucket_output_471112554792"
),
ranking as (
SELECT
    ROW_NUMBER() OVER (PARTITION BY r.rango_edad, p.posiciones_jugador ORDER BY p.salario_euros DESC) AS rank_salario,
    r.rango_edad,
    p.posiciones_jugador,
    p.nombre_largo,
    p.salario_euros
FROM "catalogos_players"."bucket_output_471112554792" as p 
INNER JOIN rangos as r ON r.id = p.id
)
SELECT rank_salario, posiciones_jugador, rango_edad, nombre_largo, salario_euros
FROM ranking WHERE rank_salario <= 10 order by rank_salario asc, posiciones_jugador asc;

---- top 10 valor
CREATE OR REPLACE VIEW top_10_rangos_edad_posicion_valor AS
with rangos as (
select  id,
case when edad >= '16' and edad <= '22' then '16-22'
when edad >= '23' and edad <= '25' then '23-25'
when edad >= '26' and edad <= '29' then '26-29'
when edad >= '30'then '30+' end as rango_edad
FROM "catalogos_players"."bucket_output_471112554792"
),
ranking as (
SELECT
    ROW_NUMBER() OVER (PARTITION BY r.rango_edad, p.posiciones_jugador ORDER BY p.valor_euros DESC) AS rank_valor,
    r.rango_edad,    
    p.posiciones_jugador,
    p.nombre_largo,
    p.valor_euros    
FROM "catalogos_players"."bucket_output_471112554792" as p 
INNER JOIN rangos as r ON r.id = p.id
)
SELECT rank_salario, posiciones_jugador, rango_edad, nombre_largo, salario_euros
FROM ranking WHERE rank_salario <= 10 order by rank_salario asc, posiciones_jugador asc;