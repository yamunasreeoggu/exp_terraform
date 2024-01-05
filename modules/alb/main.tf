#resource "aws_security_group" "sec-grp" {
#  name        = "${var.env}-${var.alb-type}-sg"
#  description = "${var.env}-${var.alb-type}-sg"
#  vpc_id      = var.vpc_id
#
#  ingress {
#    description      = "HTTP"
#    from_port        = 80
#    to_port          = 80
#    protocol         = "tcp"
#    cidr_blocks      = var.alb_sg_allow_cidr
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#
#  }
#
#  tags = {
#    Name = "${var.env}-${var.alb-type}-sg"
#  }
#}