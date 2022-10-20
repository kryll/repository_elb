
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  # ami a instalar
  ami = data.aws_ami.ubuntu.id
  # tipo de instancia
  instance_type = "t2.micro"
  # clave ssh asociada por defecto
  key_name = aws_key_pair.deployer.key_name
  # zona de disponibilidad
  availability_zone = var.availability_zone
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https]
  subnet_id = element(module.vpc.public_subnets,1)
  tags = {
    Name = "NewMachine_Ejercicio1"
  }
}
output "ip_instance" {
  value = aws_instance.web.public_ip
}

output "ssh" {
  value = "ssh -l ec2-user ${aws_instance.web.public_ip}"
}
