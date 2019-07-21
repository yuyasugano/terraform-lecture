output "rds" {
  value = "${
    map(
      "address",  "${module.db.this_db_instance_address}",
      "port",     "${module.db.this_db_instance_port}",
      "name",     "${module.db.this_db_instance_name}",
      "username", "${module.db.this_db_instance_username}",
      "sg",       "${aws_security_group.rds-sg.id}"
    )
  }"
}

