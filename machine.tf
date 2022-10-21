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

// 16kB tamaño maximo
data "template_file" "userdata" {
  template = file("${path.module}/user_data.sh")
}


resource "aws_instance" "web" {
 ami = data.aws_ami.rhel_8_5.id
 availability_zone = var.availability_zone
 instance_type = "t3.micro"
 vpc_security_group_ids = [aws_security_group.allow_ssh.id]
 user_data = data.template_file.userdata.rendered
 key_name = aws_key_pair.deployer-key.key_name
 tags = {
 Name = "web-instance"
 }
}

resource "aws_volume_attachment" "web" {
 device_name = "/dev/sdh"
 volume_id = aws_ebs_volume.web.id
 instance_id = aws_instance.web.id
}


output "ip_instance" {
  value = aws_instance.web.public_ip
}

output "ssh" {
  value = "ssh -l ec2-user ${aws_instance.web.public_ip}"
}
