import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

AmazonS3_node1712724631800 = glueContext.create_dynamic_frame.from_options(format_options={"quoteChar": "\"", "withHeader": True, "separator": ","}, connection_type="s3", format="csv", connection_options={"paths": ["s3://bucket-raw-471112554792/players_20.csv"], "recurse": True}, transformation_ctx="AmazonS3_node1712724631800")

AmazonS3_node1712724713770 = glueContext.write_dynamic_frame.from_options(frame=AmazonS3_node1712724631800, connection_type="s3", format="glueparquet", connection_options={"path": "s3://bucket-curado-471112554792", "partitionKeys": []}, format_options={"compression": "snappy"}, transformation_ctx="AmazonS3_node1712724713770")

s3_client = boto3.client('s3')
s3_client.delete_object(Bucket="bucket-raw-471112554792", Key="players_20.csv")

job.commit()