#--------------------------------------------
# VPCを設定
#--------------------------------------------
# 参考:
# - https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.60.0
# - https://github.com/terraform-aws-modules/terraform-aws-vpc/examples

# P03: AWS構築編, 7ページ目 「VPC設定」
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.60.0"

  name = "${lookup(var.vpc, "${terraform.env}.name", var.vpc["default.name"])}"
  cidr = "${lookup(var.vpc, "${terraform.env}.cidr", var.vpc["default.cidr"])}"

  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]
  # P03: AWS構築編, 10ページ目 「サブネット作成」
  # P03: AWS構築編, 15ページ目 「ルートテーブル設定」
  public_subnets = [
    "${lookup(var.vpc, "${terraform.env}.public-a", var.vpc["default.public-a"])}",
    "${lookup(var.vpc, "${terraform.env}.public-c", var.vpc["default.public-c"])}",
  ]
  private_subnets = [
    "${lookup(var.vpc, "${terraform.env}.private-a", var.vpc["default.private-a"])}",
    "${lookup(var.vpc, "${terraform.env}.private-c", var.vpc["default.private-c"])}"
  ]

  assign_generated_ipv6_cidr_block = false

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support = true

  # P03: AWS構築編, 13ページ目 「インターネットゲートフェイ設定」
  enable_nat_gateway = true
  single_nat_gateway = true
}

