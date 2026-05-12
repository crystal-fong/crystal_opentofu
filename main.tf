terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "project_name" {
  type    = string
  default = "iacm-demo"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.project_name}-bucket-${random_id.suffix.hex}"

  tags = {
    Name = "${var.project_name}-s3"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "instance_id" {
  value = aws_instance.app.id
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.storage.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.storage.arn
}
