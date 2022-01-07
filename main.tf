terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  region     = var.region
  access_key = "AKIAZVTAABCB654GV6ME"
  secret_key = "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"

}
locals {
  common_tags = {
    key   = "product-ID"
    value = "test_product"
  }
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "mybucket-25011990"
  tags   = local.common_tags
}

resource "aws_vpc" "main" {
  cidr_block         = var.vpc_cidr
  instance_tenancy   = "default"
  enable_dns_support = true
  tags               = local.common_tags
}

resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/17"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.my-az
  tags                    = local.common_tags
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/17"
  availability_zone = var.my-az
  tags              = local.common_tags
}

resource "aws_iam_role" "s3_role" {
  name = "s3_role"
  tags = local.common_tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


#IAM policy
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.s3_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::mybucket-25011990"
    }
  ]
}
EOF
}

      # "Resource": "arn:aws:s3:::mybucket-25011990"

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.s3_role.name
  tags = local.common_tags
}

resource "aws_instance" "role-test" {
  ami                    = var.ami-name
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  instance_type = var.instancetype
  #instance_type          = lookup(var.instancetype, terraform.workspace)
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = ["${aws_security_group.test-subnet-1.id}"]
  #aws_iam_role = "{aws_iam_role.s3-role.name}"
  tags     = local.common_tags
/*  key_name = "my_key"

  connection {
    type        = "ssh"
    private_key = file("./my_key")
    user        = "ec2_user"
    host        = aws_instance.role-test.public_ip
    agent       = false
  }
  */
}
  output "public-ip-addr" {
    value = aws_instance.role-test.public_ip
}

/*
variable "instancetype" {
  type = map(any)

  default = {
    default = "t2.micro"
    dev     = "t2.nano"
    prod    = "t2.large"
  }
}
*/

resource "aws_security_group" "test-subnet-1" {
  name        = "test_sg_1"
  description = "Allow traffic"
  vpc_id      = aws_vpc.main.id
  tags        = local.common_tags

  ingress {
    description = "incoming to vpc "
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outgoing from vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "elb" {
  name            = var.elb_name
  subnets         = ["${aws_subnet.subnet-1.id}"]
  security_groups = ["${aws_security_group.test-subnet-1.id}"]
  internal        = true
  tags            = local.common_tags
  #availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
    instance_port     = 443
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.role-test.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}
resource "aws_alb_target_group" "group" {
  name     = "terraform-example-alb-target"
  port     = 443
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  tags     = local.common_tags
}

resource "aws_elb_attachment" "elb-attach" {
  elb      = aws_elb.elb.id
  instance = aws_instance.role-test.id
}
