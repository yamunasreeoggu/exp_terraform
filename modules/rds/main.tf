resource "aws_security_group" "sec-grp" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "RDS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = var.vpc_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env}-${var.component}-sg"
  }
}

resource "aws_db_subnet_group" "subnet-group" {
  name       =  "${var.env}-${var.component}-subnet-group"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-${var.component}-subnet-group"
  }
}

resource "aws_rds_cluster" "rds-cluster" {
  cluster_identifier      = "${var.env}-${var.component}-rds"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.3"
  availability_zones      = var.azs
  database_name           = "mydb"
  master_username         = data.aws_ssm_parameter.rds-username.value
  master_password         = data.aws_ssm_parameter.rds-password.value
  db_subnet_group_name    = aws_db_subnet_group.subnet-group.name
}
