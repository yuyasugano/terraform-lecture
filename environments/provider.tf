provider "aws" {
  region = "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}"
  access_key = "${lookup(var.common, "${terraform.env}.access_key", var.common["default.access_key"])}"
  secret_key = "${lookup(var.common, "${terraform.env}.secret_key", var.common["default.secret_key"])}"
}

