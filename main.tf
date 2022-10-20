# Fichero main.tf
provider "aws" {
 region = "eu-west-3"
}

variable "ssh_key_path" {}
variable "availability_zone" {}

# Recurso de clave SSH en AWS
resource "aws_key_pair" "deployer" {
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

resource "aws_security_group" "allow_ssh_http_https" {
 name = "allow_ssh_http_https"
 description = "Allow SSH HTTp HTTPS inbound traffic"
 vpc_id = module.vpc.vpc_id

   ingress {
  # description = "SSH from VPC"
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
 #  description = "HTTP from VPC"
   from_port = 80
   to_port = 80
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
 #  description = "HTTPS from VPC"
   from_port = 443
   to_port = 443
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
 Name = "allow_ssh_http_https"
 }
}

