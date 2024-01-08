resource "aws_security_group" "sec-grp" {
  name        = "${var.env}-rds-sg"
  description = "${var.env}-rds-sg"
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
    Name = "${var.env}-rds-sg"
  }
}

resource "aws_db_subnet_group" "subnet-group" {
  name       =  "${var.env}-rds-subnet-group"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-rds-subnet-group"
  }
}


resource "aws_rds_cluster" "rds-cluster" {
  cluster_identifier      = "${var.env}-rds-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.3"
  database_name           = "mydb"
  master_username         = data.aws_ssm_parameter.rds-username.value
  master_password         = data.aws_ssm_parameter.rds-password.value
  db_subnet_group_name    = aws_db_subnet_group.subnet-group.name
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "${var.env}-rds-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.rds-cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.rds-cluster.engine
  engine_version     = aws_rds_cluster.rds-cluster.engine_version
}
