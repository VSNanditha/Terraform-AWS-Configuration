variable "access_key" {}

variable "secret_key" {}

variable "key_name" {}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0756fbca465a59a30"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  default = 2
}

variable "output_filename" {
  type = "string"
  default = "students.txt"
}
