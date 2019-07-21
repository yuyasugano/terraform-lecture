#--------------------------------------------
# EC2インスタンスを起動するために必要な設定を定義
#--------------------------------------------
# 参考:
# - https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/2.9.1
# - https://github.com/terraform-aws-modules/terraform-aws-autoscaling/tree/master/examples

#--------------------------------------------
# セキュリティーグループの設定
#--------------------------------------------
# EC2用のセキュリティーグループの設定 (Base設定)
resource "aws_security_group" "ec2-sg" {
  name = "${lookup(var.ec2, "${terraform.env}.name", var.ec2["default.name"])}-sg"
  description = "Security Group to ${lookup(var.ec2, "${terraform.env}.name", var.ec2["default.name"])}"
  vpc_id = "${var.vpc["vpc_id"]}"

  # まずは全拒否に設定しておく
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# EC2用のセキュリティーグループの設定 (ingress設定)
# ELBからのアクセスのみを許可する(Wordpressのページにアクセスできるようにする)
resource "aws_security_group_rule" "ec2-sg_ingress" {
  # 上記で作成したセキュリティーグループのIDを指定
  security_group_id = "${aws_security_group.ec2-sg.id}"
  type = "ingress"

  from_port = "${lookup(var.elb, "${terraform.env}.instance_port", var.elb["default.instance_port"])}"
  to_port = "${lookup(var.elb, "${terraform.env}.instance_port", var.elb["default.instance_port"])}"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.elb-sg.id}"
}

# EC2用のセキュリティーグループの設定 (ingress設定, ssh)
# 指定のIPアドレスからインスタンスへSSH接続できるようにする(オフィスからのみSSH接続できるようにする)
# P02: AWS入門編, 9ページ目 「セキュリティーグループ設定」
resource "aws_security_group_rule" "ec2_sg_ingress-office-ssh" {
  security_group_id = "${aws_security_group.ec2-sg.id}"
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  # こちらに設定されているIPアドレスからのみSSH接続できるようにする
  cidr_blocks = [
    "${lookup(var.ec2, "${terraform.env}.office_ip", var.ec2["default.office_ip"])}"
  ]
}


# RDS用のセキュリティーグループの設定の変更
resource "aws_security_group_rule" "rds-sg_ingress" {
  # 指定のRDSの
  security_group_id = "${var.rds["sg"]}"
  # ingresについて
  type = "ingress"
  # こちらのポートから
  from_port = "${var.rds["port"]}"
  # ここのポートへの
  to_port = "${var.rds["port"]}"
  # TCPアクセスを許可するよ
  protocol = "tcp"
  # 許可するのはこのセキュリティーグループが設定されているEC2インスタンス
  source_security_group_id = "${aws_security_group.ec2-sg.id}"
}

#--------------------------------------------
# IAMの設定
#--------------------------------------------
resource "aws_iam_role" "ec2" {
  name = "${lookup(var.ec2, "${terraform.env}.name", var.ec2["default.name"])}-role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {"Service": "ec2.amazonaws.com"},
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_instance_profile" "ec2" {
  name = "${lookup(var.ec2, "${terraform.env}.name", var.ec2["default.name"])}-profile"
  role = "${aws_iam_role.ec2.name}"
}

resource "aws_iam_role_policy_attachment" "policy-attach-AmazonEC2RoleforSSM" {
  role = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#--------------------------------------------
# EC2インスタンスの設定
#--------------------------------------------
# 最新のAMIイメージのIDを取得する
# refer: https://qiita.com/litencatt/items/998072fed75ba01835d4
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = [
      "${lookup(var.ec2, "${terraform.env}.instance_image_value", var.ec2["default.instance_image_value"])}",
    ]
  }
}
# EC2インスタンスの起動オプションの設定
# P02: AWS入門編, 10ページ目 「EC2インスタンス作成」
# P04 WordPress導入 9ページ目 「EC2作成」
resource "aws_launch_configuration" "this"{
  name_prefix = "${lookup(var.ec2, "${terraform.env}.name", var.ec2["default.name"])}-"
  image_id = "${data.aws_ami.amazon_linux.id}"
  instance_type = "${lookup(var.ec2, "${terraform.env}.instance_type", var.ec2["default.instance_type"])}"

  associate_public_ip_address = "${lookup(var.ec2, "${terraform.env}.associate_public_ip_address", var.ec2["default.associate_public_ip_address"])}"

  root_block_device = {
    volume_type = "${lookup(var.ec2, "${terraform.env}.volume_type", var.ec2["default.volume_type"])}"
    volume_size = "${lookup(var.ec2, "${terraform.env}.volume_size", var.ec2["default.volume_size"])}"
  }
  # 上記で作成したセキュリティーグループのIDを指定
  security_groups = [
    "${aws_security_group.ec2-sg.id}"
  ]
  # 上記で設定したIAMを指定
  iam_instance_profile = "${aws_iam_instance_profile.ec2.id}"

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 オートスケーリングの設定
module "autoscaring" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"

  name = "${lookup(var.ec2, "${terraform.env}.name", var.ec2["default.name"])}-asg"

  vpc_zone_identifier = [
    "${var.public_subnets}"
  ]
  max_size = "${lookup(var.ec2, "${terraform.env}.max_size", var.ec2["default.max_size"])}"
  min_size = "${lookup(var.ec2, "${terraform.env}.min_size", var.ec2["default.min_size"])}"
  health_check_grace_period = "${lookup(var.ec2, "${terraform.env}.health_check_grace_period", var.ec2["default.health_check_grace_period"])}"
  health_check_type = "${lookup(var.ec2, "${terraform.env}.health_check_type", var.ec2["default.health_check_type"])}"
  desired_capacity = "${lookup(var.ec2, "${terraform.env}.desired_capacity", var.ec2["default.desired_capacity"])}"

  force_delete = true
  create_lc = false

  # 上記で設定した起動オプションを選択
  launch_configuration = "${aws_launch_configuration.this.name}"

  # 作成したELBを設定
  load_balancers = [
    "${module.elb.this_elb_id}"
  ]
}

