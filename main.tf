############################################################
#                       provider
############################################################

provider "aws" {
  region = "us-east-1"
}

############################################################
#                       variables
############################################################

# Define la region
variable "region" {
  default     = "us-east-1"
  description = "AWS Region to deploy to"
}

# Define los nombres de los buckets
variable "bucket_raw" {
  default = "bucket-raw-471112554792"
}
variable "bucket_curado" {
  default = "bucket-curado-471112554792"
}
variable "bucket_output" {
  default = "bucket-output-471112554792"
}
variable "bucket_libraries" {
  default = "bucket-libraries-471112554792"
}

variable "bucket_glue_scripts" {
  default = "aws-glue-scripts-471112554792"
}


# Define el account id de la cuenta
variable "id_account" {
  default     = "471112554792"
  description = "id account"
}

variable "mover_archivo_csv" {
  default     = "mover_archivo_csv.py"
  description = "script de python para mover un archivo de un bucket a otro"
}

variable "modificar_nombres_columnas" {
  default     = "modificar_nombres_columnas.py"
  description = "script de python para modificar las columas"
}

variable "players_file" {
  default     = "players_20.csv"
  description = "archivo de carga muestra para el glue"
}

variable "librerias" {
  default     = "librerias.zip"
  description = "librerias python necesarias para el glue"
}

variable "bucket_assets" {
  default     = "aws-glue-assets-471112554792-us-east-1"
  description = "bucket para trabajo de transformación temporal"
}

#variable "bucket_transform" {
#  default     = "aws-glue-studio-transforms-510798373988-prod-us-east-1"
#  description = "bucket para trabajo de transformación temporal"
#}



############################################################
#                     resources
############################################################


#----------------------Buckets------------------------------

# Crea el bucket transform
#resource "aws_s3_bucket" "bucket_transform" {
#  bucket        = var.bucket_transform
#  force_destroy = true
#  acl           = "private"
#}

# Crea el bucket assets
resource "aws_s3_bucket" "bucket_assets" {
  bucket        = var.bucket_assets
  force_destroy = true
  acl           = "private"
}

# Crea el bucket raw
resource "aws_s3_bucket" "bucket_raw" {
  bucket        = var.bucket_raw
  force_destroy = true
  acl           = "private"
}

# Crea el bucket curado
resource "aws_s3_bucket" "bucket_curado" {
  bucket        = var.bucket_curado
  force_destroy = true
  acl           = "private"
}

# Crea el bucket output
resource "aws_s3_bucket" "bucket_output" {
  bucket        = var.bucket_output
  force_destroy = true
  acl           = "private"
}

# Crea el bucket para las librerias de python
resource "aws_s3_bucket" "bucket_libraries" {
  bucket        = var.bucket_libraries
  force_destroy = true
  acl           = "private"
}

# Crea el bucket de S3 para almacenar los scripts de Glue
resource "aws_s3_bucket" "glue_scripts_bucket" {
  bucket        = var.bucket_glue_scripts
  force_destroy = true
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


#______________________Bucket Objects----------------------


resource "aws_s3_bucket_object" "modificar_nombres_columnas_script" {
  bucket = aws_s3_bucket.glue_scripts_bucket.bucket
  key    = "glue_scripts/${var.modificar_nombres_columnas}"
  source = var.modificar_nombres_columnas
}

resource "aws_s3_bucket_object" "mover_archivo_csv" {
  bucket = aws_s3_bucket.glue_scripts_bucket.bucket
  key    = "glue_scripts/${var.mover_archivo_csv}"
  source = var.mover_archivo_csv
}

resource "aws_s3_bucket_object" "players" {
  bucket = aws_s3_bucket.bucket_raw.bucket
  key    = var.players_file
  source = var.players_file
}

resource "aws_s3_bucket_object" "librerias" {
  bucket = aws_s3_bucket.bucket_libraries.bucket
  key    = var.librerias
  source = var.librerias
}

#----------------------Glue Jobs---------------------------

# Define el primer flujo de AWS Glue para mover el archivo CSV de raw a curado y convertirlo a formato Parquet
resource "aws_glue_job" "mover_archivo_csv" {
  name        = "mover_archivo_csv"
  description = "Job para mover un archivo csv y dejarlo como parquet"

  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts_bucket.bucket}/glue_scripts/${aws_s3_bucket_object.mover_archivo_csv.source}"
    python_version  = 3
  }

  default_arguments = {
    "--bucket_origen"  = "s3://${aws_s3_bucket.bucket_raw.bucket}"
    "--bucket_destino" = "s3://${aws_s3_bucket.bucket_curado.bucket}"
    "--extra-py-files" = "s3://${aws_s3_bucket.bucket_libraries.bucket}/${var.librerias}"
    #temp_dir = ""
  }

  worker_type       = "G.1X"
  number_of_workers = 2


}

# Define el segundo flujo de AWS Glue para modificar nombres de columnas y mover el archivo de curado a output
resource "aws_glue_job" "modificar_nombres_columnas" {
  name        = "modificar_nombres_columnas"
  description = "Job para la modificación de nombres"

  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts_bucket.bucket}/glue_scripts/${aws_s3_bucket_object.modificar_nombres_columnas_script.source}"
    python_version  = 3
  }

  default_arguments = {
    "--bucket_origen"  = "s3://${aws_s3_bucket.bucket_curado.bucket}"
    "--bucket_destino" = "s3://${aws_s3_bucket.bucket_output.bucket}"
    "--extra-py-files" = "s3://${aws_s3_bucket.bucket_libraries.bucket}/${var.librerias}"
  }

  worker_type       = "G.1X"
  number_of_workers = 2
}

#----------------------Catalog Database---------------------------

# Define la base de datos de Athena
resource "aws_glue_catalog_database" "my_database" {
  name = "catalogos_players"
}

resource "aws_glue_catalog_table" "my_table" {
  database_name = "catalogos_players"
  name          = "players"
  depends_on = [ aws_glue_catalog_database.my_database ]
}

# Define el Crawler de Glue para el segundo flujo
resource "aws_glue_crawler" "crawler_output" {
  name          = "crawler_output"
  database_name = aws_glue_catalog_database.my_database.name
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.bucket_output.bucket}/"
  }

  depends_on = [aws_glue_job.modificar_nombres_columnas]
}

#---------------------- Roles ---------------------------

# Define un rol de IAM para los flujos de Glue
resource "aws_iam_role" "glue_role" {
  name = "glue_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "glue_role"
  }
}


#---------------------- Policies ---------------------------

# Define la política de IAM para permitir acceso a los scripts en el bucket de S3
resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = "glue_s3_access_policy"
  description = "Política de IAM para permitir acceso a los scripts de Glue en un bucket de S3"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      #{
      #  "Effect" : "Allow",
      #  "Action" : [
      #    "s3:ListBucket",
      #    "s3:GetObject",
      #    "s3:CopyObject",
      #    "s3:HeadObject",
      #    "s3:PutObject",
      #    "s3:DeleteObject"
      #  ],
      #  "Resource" : [
      #
      #    "arn:aws:s3:::aws-glue-studio-transforms-510798373988-prod-us-east-1/*",
      #    "arn:aws:s3:::aws-glue-studio-transforms-510798373988-prod-us-east-1/"
      #  ]
      #},
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [

          "${aws_s3_bucket.bucket_assets.arn}/*",
          "${aws_s3_bucket.bucket_assets.arn}/"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [

          "${aws_s3_bucket.glue_scripts_bucket.arn}/*",
          "${aws_s3_bucket.glue_scripts_bucket.arn}/"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [

          "${aws_s3_bucket.bucket_libraries.arn}/*",
          "${aws_s3_bucket.bucket_libraries.arn}/"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [


          "${aws_s3_bucket.bucket_raw.arn}/*",
          "${aws_s3_bucket.bucket_raw.arn}/"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.bucket_curado.arn}/*",
          "${aws_s3_bucket.bucket_curado.arn}/"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.bucket_output.arn}/*",
          "${aws_s3_bucket.bucket_output.arn}/"
        ]
      },
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Asocia la política al rol de IAM
resource "aws_iam_role_policy_attachment" "glue_s3_access_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}


resource "aws_iam_role_policy" "glue_role_policy" {
  name = "glue_role_policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "glue:GetDatabase",
          "glue:GetTables",
          "glue:GetTable",
          "glue:CreateDatabase",
          "glue:CreateTable",
          "glue:BatchDeleteTable",
          "glue:BatchCreatePartition",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:CreatePartition",
          "glue:DeletePartition"
        ],
        "Resource" : [
          "${aws_s3_bucket.bucket_raw.arn}/*",
          "${aws_s3_bucket.bucket_curado.arn}/*",
          "${aws_glue_catalog_database.my_database.arn}",
          "${aws_glue_catalog_table.my_table.arn}",
          "${aws_s3_bucket.bucket_output.arn}/*",
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        "Resource" : "*"
      }
    ]
  })
}

