-- top  5 jugadores efectivos posicion
CREATE OR REPLACE VIEW top_5_jugadores_efectivos_posicion AS
WITH sumas AS (SELECT
id,
CAST(replace(movimientos_calidad, '','0') AS integer) + 
CAST(replace(ritmo_jugador, '','0') AS integer) + 
CAST(replace(disparo, '','0') AS integer) + 
CAST(replace(pase, '','0') AS integer) + 
CAST(replace(dribbling, '','0') AS integer) + 
CAST(replace(defensa, '','0') AS integer) + 
CAST(replace(fisico, '','0') AS integer) + 
CAST(replace(cruce_ataque, '','0') AS integer) + 
CAST(replace(finalidad_ataque, '','0') AS integer) + 
CAST(replace(exactitud_ataque_cabeza, '','0') AS integer) + 
CAST(replace(ataque_pase_corto, '','0') AS integer) + 
CAST(replace(disparo_jugador, '','0') AS integer) + 
CAST(replace(habilidad_dribling, '','0') AS integer) + 
CAST(replace(habilidad_curva, '','0') AS integer) + 
CAST(replace(habilidad_fk_exactitud, '','0') AS integer) + 
CAST(replace(habilidad_pase_largo, '','0') AS integer) + 
CAST(replace(habilidad_control_balon, '','0') AS integer) + 
CAST(replace(aceleracion_movimiento, '','0') AS integer) + 
CAST(replace(movimiento_velocididad_aceleracion, '','0') AS integer) + 
CAST(replace(agilidad_movimiento, '','0') AS integer) + 
CAST(replace(reacciones_movimiento, '','0') AS integer) + 
CAST(replace(balance_movimiento, '','0') AS integer) + 
CAST(replace(poder_disparo, '','0') AS integer) + 
CAST(replace(poder_salto, '','0') AS integer) + 
CAST(replace(poder_aguante, '','0') AS integer) + 
CAST(replace(poder_fortaleza, '','0') AS integer) + 
CAST(replace(poder_disparos_largo, '','0') AS integer)
AS suma_criterios
FROM "catalogos_players"."bucket_output_471112554792"
),
ranking as (
SELECT p.id, p.nombre_largo, p.posiciones_jugador,
ROW_NUMBER() OVER (PARTITION BY p.posiciones_jugador ORDER BY s.suma_criterios DESC) AS rank_efectivos
FROM "catalogos_players"."bucket_output_471112554792" as p
INNER JOIN sumas as s ON s.id = p.id
)
SELECT rank_efectivos, nombre_largo, posiciones_jugador
FROM ranking WHERE rank_efectivos <= 5 order by rank_efectivos asc;