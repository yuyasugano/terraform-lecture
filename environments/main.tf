module "vpc" {
  source = "../modules/vpc"
  common = "${var.common}"
  vpc = "${var.vpc}"
}

module "rds" {
  source = "../modules/db"
  common = "${var.common}"
  rds = "${var.rds}"

  vpc = "${module.vpc.vpc}"
  private_subnets = "${module.vpc.private_subnets}"
}

module "compute" {
  source = "../modules/compute"
  common = "${var.common}"
  ec2 = "${var.ec2}"
  elb = "${var.elb}"
  rds = "${module.rds.rds}"

  vpc = "${module.vpc.vpc}"
  public_subnets = "${module.vpc.public_subnets}"
  private_subnets = "${module.vpc.private_subnets}"
}

