# RHEL 8.5
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name      = "name"
    values    = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name      = "virtualization-type"
    values    = ["hvm"]
  }

  owners      = ["099720109477"] # Canonical
}



output "ip_instance" {
  value = aws_instance.web.public_ip
}

output "ssh" {
  value = "ssh -l ubuntu ${aws_instance.web.public_ip}"
}

output "eip_ip" {
  description = "The eip ip for ssh access"
  value       = aws_eip.eip.public_ip
}