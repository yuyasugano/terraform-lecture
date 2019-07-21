#--------------------------------------------
# RDSを起動するために必要な設定を定義
#--------------------------------------------
# 参考:
# - https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/1.27.0
# - https://github.com/terraform-aws-modules/terraform-aws-rds/tree/master/examples

#--------------------------------------------
# RDS用セキュリテイーグループの設定
#--------------------------------------------
# P03: AWS構築編, 17ページ目 「セキュリティーグループ設定」
resource "aws_security_group" "rds-sg" {
  name = "${lookup(var.rds, "${terraform.env}.name", var.rds["default.name"])}-sg"
  description = "Security Group to ${lookup(var.rds, "${terraform.env}.name", var.rds["default.name"])}"
  vpc_id = "${lookup(var.vpc, "vpc_id")}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

#--------------------------------------------
# RDSインスタンスの設定
#--------------------------------------------
# P04 WordPress導入 7ページ目 「RDS設定」
module "db" {
  # https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/1.27.0
  source = "terraform-aws-modules/rds/aws"
  version = "1.27.0"

  identifier = "${lookup(var.rds, "${terraform.env}.identifier", var.rds["default.identifier"])}"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine = "${lookup(var.rds, "${terraform.env}.engine", var.rds["default.engine"])}"
  engine_version = "${lookup(var.rds, "${terraform.env}.engine_version", var.rds["default.engine_version"])}"
  instance_class = "${lookup(var.rds, "${terraform.env}.instance_class", var.rds["default.instance_class"])}"
  allocated_storage = "${lookup(var.rds, "${terraform.env}.allocated_storage", var.rds["default.allocated_storage"])}"
  storage_encrypted = false
  major_engine_version = "${lookup(var.rds, "${terraform.env}.major_engine_version", var.rds["default.major_engine_version"])}"

  name = "${lookup(var.rds, "${terraform.env}.name", var.rds["default.name"])}"
  username = "${lookup(var.rds, "${terraform.env}.db_user_name", var.rds["default.db_user_name"])}"
  password = "${lookup(var.rds, "${terraform.env}.db_password", var.rds["default.db_password"])}"
  port = "${lookup(var.rds, "${terraform.env}.port", var.rds["default.port"])}"

  vpc_security_group_ids = [
    "${aws_security_group.rds-sg.id}"
  ]

  maintenance_window = "${lookup(var.rds, "${terraform.env}.maintenace_window", var.rds["default.maintenace_window"])}"
  backup_window = "${lookup(var.rds, "${terraform.env}.backup_window", var.rds["default.backup_window"])}"
  backup_retention_period = "${lookup(var.rds, "${terraform.env}.backup_retention_period", var.rds["default.backup_retention_period"])}"

  multi_az = "${lookup(var.rds, "${terraform.env}.multi_az", var.rds["default.multi_az"])}"

  #--------------------------------------------
  # サブネットの設定
  #--------------------------------------------
  subnet_ids = "${var.private_subnets}"

  #--------------------------------------------
  # RDSのパラメーターの設定
  #--------------------------------------------
  family = "${lookup(var.rds, "${terraform.env}.family", var.rds["default.family"])}"
}

