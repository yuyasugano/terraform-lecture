variable "common" {
  type = "map"
  default = {}
}

variable "elb" {
  type = "map"
  default = {}
}

variable "ec2" {
  type = "map"
  default = {}
}

variable "rds" {
  type = "map"
  default = {}
}
variable "vpc" {
  type = "map"
  default = {}
}

variable "public_subnets" {
  type = "list"
  default = []
}

variable "private_subnets" {
  type = "list"
  default = []
}

