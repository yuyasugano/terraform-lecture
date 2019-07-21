#--------------------------------------------
# 作成するEC2に設定するELBの設定を定義
#--------------------------------------------
# 参考:
# - https://registry.terraform.io/modules/terraform-aws-modules/elb/aws/1.4.1
# - https://github.com/terraform-aws-modules/terraform-aws-elb/tree/master/examples/complete

#--------------------------------------------
# セキュリティーグループの設定
#--------------------------------------------
# P04 WordPress導入 18,19ページ目 「ロードバランサー設定」
resource "aws_security_group" "elb-sg" {
  name = "${lookup(var.elb, "${terraform.env}.name", var.elb["default.name"])}-sg"
  description = "Allow all inbound traffic"
  vpc_id = "${lookup(var.vpc, "vpc_id")}"

  # アクセスを許可するポートを設定
  ingress {
    from_port = "${lookup(var.elb, "${terraform.env}.lb_port", var.elb["default.lb_port"])}"
    to_port = "${lookup(var.elb, "${terraform.env}.lb_port", var.elb["default.lb_port"])}"
    protocol = "${lookup(var.elb, "${terraform.env}.protocol", var.elb["default.protocol"])}"
    cidr_blocks = [
      "${lookup(var.elb, "${terraform.env}.cidr_blocks", var.elb["default.cidr_blocks"])}"]
  }

  # 基本egress(拒否するポート)は全アクセスを拒否するように設定しておく
  # そしてingressにて許可するポート, IPアドレス、グループ名を指定する
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

#--------------------------------------------
# ELBの設定
#--------------------------------------------
# P04 WordPress導入 18,19ページ目 「ロードバランサー設定」
module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "1.4.1"

  name = "${lookup(var.elb, "${terraform.env}.name", var.elb["default.name"])}"

  subnets = "${var.public_subnets}"
  security_groups = [
    "${aws_security_group.elb-sg.id}",
  ]
  internal = "${lookup(var.elb, "${terraform.env}.internal", var.elb["default.internal"])}"

  listener = [
    {
      instance_port = "${lookup(var.elb, "${terraform.env}.instance_port", var.elb["default.instance_port"])}"
      instance_protocol = "${lookup(var.elb, "${terraform.env}.instance_protocol", var.elb["default.instance_protocol"])}"
      lb_port = "${lookup(var.elb, "${terraform.env}.lb_port", var.elb["default.lb_port"])}"
      lb_protocol = "${lookup(var.elb, "${terraform.env}.lb_protocol", var.elb["default.lb_protocol"])}"
    },
  ]

  health_check = [
    {
      healthy_threshold = "${lookup(var.elb, "${terraform.env}.healthy_threshold", var.elb["default.healthy_threshold"])}"
      unhealthy_threshold = "${lookup(var.elb, "${terraform.env}.unhealthy_threshold", var.elb["default.unhealthy_threshold"])}"
      timeout = "${lookup(var.elb, "${terraform.env}.timeout", var.elb["default.timeout"])}"
      target = "${lookup(var.elb, "${terraform.env}.target", var.elb["default.target"])}"
      interval = "${lookup(var.elb, "${terraform.env}.interval", var.elb["default.interval"])}"
    },
  ]
}

