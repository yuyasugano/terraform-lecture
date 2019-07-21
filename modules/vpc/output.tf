output "vpc" {
  value = "${
    map(
      "vpc_id", "${module.vpc.vpc_id}"
    )
  }"
}

output "common" {
  value = "${var.common}"
}

// 上記のmap内にList型の値を代入することは現在まだできないため別変数として定義しています
// https://github.com/hashicorp/terraform/issues/12294
output "private_subnets" {
  description = "List of IDs of private subnets"
  value = [
    "${module.vpc.private_subnets}"]
}

// 同上
output "public_subnets" {
  description = "List of IDs of public subnets"
  value = [
    "${module.vpc.public_subnets}"]
}

