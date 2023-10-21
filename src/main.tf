terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}
#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
#Create EC2 Instance
resource "aws_instance" "jenkins-ec2" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # free tier
  instance_type          = "t2.micro"
  subnet_id     = "subnet-06eb1d0c108bdb949"
  key_name               = "terraformjenkins"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  user_data              = file("install_jenkins.sh")
  
  
  tags = {
    Name = "jenkins"
  }
}  

#Create security group 
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow inbound ports 22, 8080"
  vpc_id      = "vpc-09f6300090f71c34b"

  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 8080 Traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "jenkins-s3-bucket-jenkins"

  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}