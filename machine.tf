# RHEL 8.5
data "aws_ami" "rhel_8_5" {
  most_recent = true
  owners = ["309956199498"] // Red Hat's Account ID
  filter {
    name   = "name"
    values = ["RHEL-8.5*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  # ami a instalar
  ami = data.aws_ami.rhel_8_5.id
  # tipo de instancia
  instance_type = "t2.micro"
  # clave ssh asociada por defecto
  key_name = aws_key_pair.deployer.key_name
  # zona de disponibilidad
  availability_zone = var.availability_zone
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = element(module.vpc.public_subnets,1)
  tags = {
    Name = "HelloWorld"
  }
}
output "ip_instance" {
  value = aws_instance.web.public_ip
}

output "ssh" {
  value = "ssh -l ec2-user ${aws_instance.web.public_ip}"
}
