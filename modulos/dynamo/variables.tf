variable "nombre_dynamoDB" {
  description = "nombre de la base de datos en dynamoDb"
  type        = string
}

variable "hash_key" {
  description = "Columna principal de la dynamoDB"
  type        = map(string)
}