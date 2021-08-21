provider "aws" {
  region     = "us-east-1"
  access_key = "MY_ACCESS_KEY"
  secret_key = "MY_ACCESS_KEY"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0057d8e6fb0692b80"
  instance_type = "t2.micro"
  key_name      = "devops-ousmanou"

  tags = {
    Name = "ec2-ousmanou"
  } 
  root_block_device {
    delete_on_termination = true
  }
}
