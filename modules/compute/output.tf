output "ec2" {
  value = "${
    map(
      "launch_configuration_id", "${module.autoscaring.this_launch_configuration_id}"
    )
  }"
}

