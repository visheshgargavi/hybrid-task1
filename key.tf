provider "aws" {
  region   = "ap-south-1"
  profile  = "myvishesh"
}

resource "aws_key_pair" "task1-key" {
  key_name    = "task1-key"
  public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzXD5tF1G5oF3StxzKbT3TvwtL2P/ZotKFARLsZr7KEfaHU4ZPA3q3dcnkum67HpNV4p/v8EIIUFFsX2ZuxH2sN5UYKDm6WmPdII+vkc+JBE65/CiK2m5RJ7mwclgJpQuNdYdREzA79FX+ZFTyBlt/KMwb06wcgWonYPpWcVxujpIot2rag+ZA5TcR5KyZKSfdM7AlMLUHARPAKjo2ikmvccNSLxg2P6AJf7Epgb0rvfb3skv34w0EslQSZD/s/nSmNifcVSVXTKeggAUlIMC17Od+YwfUM0dFgQNpF54WJzvaRF2tFv5pMQFRr6qLQBNFoe8ezvz2b26m9gMAwX0l"
}

resource "aws_security_group" "task1-sg" {
  name        = "task1-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-15f8e57d"


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task1-sg"
  }
}

resource "aws_ebs_volume" "task1-ebs" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = {
    Name = "task1-ebs"
  }
}
resource "aws_volume_attachment" "task1-attach" {
 device_name = "/dev/sdf"
 volume_id = "${aws_ebs_volume.task1-ebs.id}"
 instance_id = "${aws_instance.task1-inst.id}"
}
resource "aws_instance" "task1-inst" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name      = "task1-key"
  security_groups = [ "task1-sg" ]
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo yum install git -y
                mkfs.ext4 /dev/xvdf1
                mount /dev/xvdf1 /var/www/html
                cd /var/www/html
                git clone https://github.com/visheshgargavi/hybrid-task1
                
  EOF

  tags = {
    Name = "task1-inst"
  }
}