variable "instancetype" {
  default = "t2.micro"
}
variable "ami-name" {
  default = "ami-00f7e5c52c0f43726"
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "elb_name" {
  default = "my-elb"
}

variable "my-az" {
  default = "us-west-2a"
  #default = ["us-west-2a","us-west-2b",us-west-2c"]
}

/*
variable "timeout" {
  type = number
}


variable "public_subnet" {
  type    = "list"
  default = []
}
*/
