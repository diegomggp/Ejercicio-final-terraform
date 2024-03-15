# ---------------------------------------
# Define una instancia EC2 con AMI Ubuntu
# ---------------------------------------
resource "aws_instance" "instancia-ec2"{
  ami = var.ami_id
  instance_type = var.tipo_instancia
  vpc_security_group_ids = [ aws_security_group.mi_grupo_de_seguridad.id ]
  subnet_id              = data.aws_subnet.public_subnet.id
  #### NUEVO
  // Escribimos un "here document" que es
  // usado durante la inicialización
  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "public_subnet" {
  availability_zone = "eu-west-3a"
}

# ------------------------------------------------------
# Define un grupo de seguridad con acceso al puerto 8080
# ------------------------------------------------------
resource "aws_security_group" "mi_grupo_de_seguridad" {
  name   = "primer-servidor-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso desde el exterior"
    from_port   = var.puerto_servidor
    to_port     = var.puerto_servidor
    protocol    = "TCP"
  }
}