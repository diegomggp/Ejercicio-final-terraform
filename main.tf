# -------------------------
# Define el provider de AWS
# -------------------------
provider "aws" {
  region = local.region
}

locals {
  region          = "eu-west-3"
  nombre-bucket =   "bucket-terraform-renzo"
  nombre_dynamoDB = "dynamodb-terraform-renzo"
  nombre-ec2 =      "instancia-terraform"
  nombre_lambda=    "lambda_terraform"
  columna_dynamo =  { name="ID", type="N" }
  ami    =          "ami-05b5a865c3579bbc4"
  puerto_servidor = "8080"
  runtime_lambda = "python3.11"
  codigo_lambda  = "code.zip"
  permisos_lambda     = ["AmazonDynamoDBFullAccess", "AmazonS3ReadOnlyAccess"]
  handler_nombre = "function.lambda_handler"


}

# -------------------------
# Define el bucket S3
# -------------------------
module "bucket-s3" {
    source = "./modulos/bucket-s3"
    nombre-bucket = local.nombre-bucket

}

# -------------------------
# Define la dynamoDB
# -------------------------
module "dynamo" {
    source = "./modulos/dynamo"
    nombre_dynamoDB = local.nombre_dynamoDB
    hash_key = local.columna_dynamo
}

# -------------------------
# Define la EC2
# -------------------------
module "instancia" {
    source = "./modulos/instancia"
    ami_id = local.ami
    tipo_instancia = "t2.micro"
    puerto_servidor =   local.puerto_servidor
}

data "aws_iam_policy" "permisos" {
  count = length(local.permisos_lambda)
  name = local.permisos_lambda[count.index]
}

# -------------------------
# Define la Lambda
# -------------------------
module "lambda" {
  source = "./modulos/lambda"
  nombre_lambda = local.nombre_lambda
  permisos       = [ for permiso in data.aws_iam_policy.permisos : permiso.arn ]
  runtime_lambda = local.runtime_lambda
  codigo  = local.codigo_lambda
  lambda_handler = local.handler_nombre
}

# -------------------------
# Permitir al bucket invocar a la lambda
# -------------------------

resource "aws_lambda_permission" "permitir_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn_lambda
  principal     = "s3.amazonaws.com"
  source_arn    = module.bucket-s3.info_bucket.arn
}
# -------------------------
# Define el trigger de la lambda
# -------------------------
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket                = module.bucket-s3.info_bucket.id

  lambda_function {
    lambda_function_arn = module.lambda.arn_lambda
    events              = ["s3:ObjectCreated:*"]
  }
}
