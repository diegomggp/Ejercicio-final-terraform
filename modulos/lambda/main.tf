# ---------------------------------------
# Define una funcion Lambda
# ---------------------------------------
resource "aws_lambda_function" "lambda_terraform" {
  filename      = "modulos/lambda/code/code.zip"
  function_name = var.nombre_lambda
  role          = aws_iam_role.rol_lambda.arn
  handler = var.lambda_handler
  runtime = var.runtime_lambda
}

# ---------------------------------------
# Guarda el codigo de la lambda en un fichero zip
# ---------------------------------------
data archive_file "codigo_lambda" {
type        = "zip"
source_dir  = "modulos/lambda/code/"
output_path = "modulos/lambda/code/code.zip"
}

# ---------------------------------------
# Define el rol de la Lambda
# ---------------------------------------
resource "aws_iam_role" "rol_lambda" {
  name = "rol_${var.nombre_lambda}"
  managed_policy_arns  = var.permisos
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}