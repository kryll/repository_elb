# Fichero main.tf
provider "aws" {
 region = "eu-west-3"
}

variable "ssh_key_path" {}

# Recurso de clave SSH en AWS
resource "aws_key_pair" "deployer" {
 key_name = "deployer-key"
 public_key = file(var.ssh_key_path)
 tags = {
    Name = "jamezcua-ssh"
 }
}