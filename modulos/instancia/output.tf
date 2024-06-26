output "instancia_ids" {
  description = "IDs de las instancias"
  value = "http://${aws_instance.instancia-ec2.public_dns}:8080"
}