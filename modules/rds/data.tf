data "aws_ssm_parameter" "rds-username" {
  name = "${var.env}.rds.master_username"
}

data "aws_ssm_parameter" "rds-password" {
  name = "${var.env}.rds.master_password"
}