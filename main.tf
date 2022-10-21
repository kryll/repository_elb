# Fichero main.tf
provider "aws" {
 region = "eu-west-3"
}

variable "ssh_key_path" {}
variable "availability_zone" {}
variable "project_name" {}

# Recurso de clave SSH en AWS
resource "aws_key_pair" "deployer-key" {
 key_name = "deployer-key"
 public_key = file(var.ssh_key_path)
 tags = {
    Name = "jamezcua-ssh"
 }
}


module "vpc" {
 source = "terraform-aws-modules/vpc/aws"
 name = "vpc-main"
 cidr = "10.0.0.0/16"
 azs = [var.availability_zone]
 private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
 public_subnets = ["10.0.100.0/24", "10.0.101.0/24"]
 enable_dns_hostnames = true
 enable_dns_support = true
 enable_nat_gateway = false
 enable_vpn_gateway = false
 tags = { Terraform = "true", Environment = "dev" }
}

resource "aws_security_group" "allow_ssh_http" {
 name = "allow_ssh_http"
 description = "Allow SSH inbound traffic"
 vpc_id = module.vpc.vpc_id

ingress {
 from_port = 22
 to_port = 22
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
 from_port = 80
 to_port = 80
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }

egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
 Name = "allow_ssh"
 }
}

// 16kB tamaño maximo
data "template_file" "userdata" {
  template = file("${path.module}/user_data.sh")
}


resource "aws_instance" "web" {
 ami = data.aws_ami.ubuntu.id
 instance_type = "t3.micro"
 key_name = aws_key_pair.deployer-key.key_name
 vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
 user_data = data.template_file.userdata.rendered
 subnet_id = element(module.vpc.public_subnets,1)
 tags = {
 Name = "web-instance"
 }
}

resource "aws_volume_attachment" "web" {
 device_name = "/dev/sdh"
 volume_id = aws_ebs_volume.web.id
 instance_id = aws_instance.web.id
}

#definición del recurso EBS
resource "aws_ebs_volume" "web" {
 availability_zone = var.availability_zone
 size = 4
 type = "gp3"
 encrypted = true
 tags = {
 Name = "web-ebs"
 }
}

resource "aws_eip" "eip" {
  instance      = aws_instance.web.id
  vpc           = true
  tags          = {
    Name        = "${var.project_name}-web-epi"
  }
}

