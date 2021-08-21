provider "aws" {
  region     = "us-east-1"
  access_key = "MY_ACCESS_KEY"
  secret_key = "MY_ACCESS_KEY"
}

data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


resource "aws_instance" "myec2" {
  ami           = data.aws_ami.ec2_ami.id
  instance_type = var.instancetype
  key_name      = "devops-ousmanou"

  tags            = var.tag_prenom
  security_groups = ["${aws_security_group.security_group.name}"]
  root_block_device {
    delete_on_termination = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("./devops-ousmanou.pem")
    host = self.public_ip
  }
  }
}

resource "aws_security_group" "security_group" {
  name        = "allo_http_https_ssh"
  description = "allo inbound outbount traffic"
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.myec2.id
  vpc      = true
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${aws_eip.lb.public_ip} ;${aws_instance.myec2.id}; ${aws_instance.myec2.availability_zone}; >> infos_ec2.txt"
  }
}
