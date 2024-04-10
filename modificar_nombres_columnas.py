import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Amazon S3
AmazonS3_node1712728781139 = glueContext.create_dynamic_frame.from_options(
    format_options={},
    connection_type="s3",
    format="parquet",
    connection_options={"paths": ["s3://bucket-curado-471112554792"], "recurse": True},
    transformation_ctx="AmazonS3_node1712728781139",
)

# Script generated for node Change Schema
ChangeSchema_node1712729262624 = ApplyMapping.apply(
    frame=AmazonS3_node1712728781139,
    mappings=[
        ("sofifa_id", "string", "id", "string"),
        ("player_url", "string", "url_jugador", "string"),
        ("short_name", "string", "nombre_corto", "string"),
        ("long_name", "string", "nombre_largo", "string"),
        ("age", "string", "edad", "string"),
        ("dob", "string", "fecha_nacimiento", "string"),
        ("height_cm", "string", "altura_cm", "string"),
        ("weight_kg", "string", "peso_kg", "string"),
        ("nationality", "string", "nacionalidad", "string"),
        ("club", "string", "club", "string"),
        ("overall", "string", "general", "string"),
        ("potential", "string", "potencial", "string"),
        ("value_eur", "string", "valor_euros", "string"),
        ("wage_eur", "string", "salario_euros", "string"),
        ("player_positions", "string", "posiciones_jugador", "string"),
        ("preferred_foot", "string", "pie_preferido", "string"),
        ("international_reputation", "string", "reputacion_internacional", "string"),
        ("weak_foot", "string", "pie_debil", "string"),
        ("skill_moves", "string", "movimientos_calidad", "string"),
        ("work_rate", "string", "ritmo_trabajo", "string"),
        ("body_type", "string", "tipo_cuerpo", "string"),
        ("real_face", "string", "cara_real", "string"),
        ("release_clause_eur", "string", "clausula_liberacion_euros", "string"),
        ("team_position", "string", "posicion_equipo", "string"),
        ("team_jersey_number", "string", "numero_camiseta", "string"),
        ("joined", "string", "fecha_ingreso", "string"),
        ("contract_valid_until", "string", "contrato_valido_hasta", "string"),
        ("pace", "string", "ritmo_jugador", "string"),
        ("shooting", "string", "disparo", "string"),
        ("passing", "string", "pase", "string"),
        ("dribbling", "string", "dribbling", "string"),
        ("defending", "string", "defensa", "string"),
        ("physic", "string", "fisico", "string"),
        ("attacking_crossing", "string", "cruce_ataque", "string"),
        ("attacking_finishing", "string", "finalidad_ataque", "string"),
        ("attacking_heading_accuracy", "string", "exactitud_ataque_cabeza", "string"),
        ("attacking_short_passing", "string", "ataque_pase_corto", "string"),
        ("attacking_volleys", "string", "disparo_jugador", "string"),
        ("skill_dribbling", "string", "habilidad_dribling", "string"),
        ("skill_curve", "string", "habilidad_curva", "string"),
        ("skill_fk_accuracy", "string", "habilidad_fk_exactitud", "string"),
        ("skill_long_passing", "string", "habilidad_pase_largo", "string"),
        ("skill_ball_control", "string", "habilidad_control_balon", "string"),
        ("movement_acceleration", "string", "aceleracion_movimiento", "string"),
        (
            "movement_sprint_speed",
            "string",
            "movimiento_velocididad_aceleracion",
            "string",
        ),
        ("movement_agility", "string", "agilidad_movimiento", "string"),
        ("movement_reactions", "string", "reacciones_movimiento", "string"),
        ("movement_balance", "string", "balance_movimiento", "string"),
        ("power_shot_power", "string", "poder_disparo", "string"),
        ("power_jumping", "string", "poder_salto", "string"),
        ("power_stamina", "string", "poder_aguante", "string"),
        ("power_strength", "string", "poder_fortaleza", "string"),
        ("power_long_shots", "string", "poder_disparos_largo", "string"),
        ("mentality_aggression", "string", "mentalidad_agresion", "string"),
        ("mentality_interceptions", "string", "mentalidad_intercepcion", "string"),
        ("mentality_positioning", "string", "mentalidad_posicionamiento", "string"),
        ("mentality_vision", "string", "mentalidad_vision", "string"),
        ("mentality_penalties", "string", "mentalidad_penales", "string"),
        ("mentality_composure", "string", "mentalidad_compostura", "string"),
        ("defending_marking", "string", "defensa_marca", "string"),
        ("defending_standing_tackle", "string", "defensa_ataque_de_pie", "string"),
        ("defending_sliding_tackle", "string", "defensa_corrediza_de_pie", "string"),
        ("goalkeeping_diving", "string", "portero_salto", "string"),
        ("goalkeeping_handling", "string", "portero_contencion", "string"),
        ("goalkeeping_kicking", "string", "portero_pateo", "string"),
        ("goalkeeping_positioning", "string", "portero_posicionamiento", "string"),
        ("goalkeeping_reflexes", "string", "portero_reflejos", "string"),
    ],
    transformation_ctx="ChangeSchema_node1712729262624",
)

# Script generated for node Amazon S3
AmazonS3_node1712729265637 = glueContext.getSink(
    path="s3://bucket-output-471112554792",
    connection_type="s3",
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=[],
    enableUpdateCatalog=True,
    transformation_ctx="AmazonS3_node1712729265637",
)
AmazonS3_node1712729265637.setCatalogInfo(
    catalogDatabase="catalogos_players", catalogTableName="players"
)
AmazonS3_node1712729265637.setFormat("glueparquet", compression="snappy")
AmazonS3_node1712729265637.writeFrame(ChangeSchema_node1712729262624)
job.commit()
