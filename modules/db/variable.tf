variable "common" {
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

//modules/vpc/output.tf のコメントを確認
variable "private_subnets" {
  type = "list"
  default = []
}

