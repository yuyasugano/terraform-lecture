output "common" {
  value = "${var.common}"
}

output "vpc" {
  value = "${module.vpc.vpc}"
}

output "private_subnets" {
  value = ["${module.vpc.private_subnets}"]
}

output "public_subnets" {
  value = ["${module.vpc.public_subnets}"]
}

output "rds" {
  value = "${module.rds.rds}"
}

