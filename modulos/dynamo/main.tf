# ---------------------------------------
# Define una DybamoDB
# 
resource "aws_dynamodb_table" "dynamoDB-ejercicio-terraform" {
  name           = var.nombre_dynamoDB
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key.name

  attribute {
    name = var.hash_key.name
    type = var.hash_key.type
  }
}