resource "aws_security_group" "sec-grp" {
  name        = "${var.env}-${var.alb-type}-sg"
  description = "${var.env}-${var.alb-type}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.alb_sg_allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env}-${var.alb-type}-sg"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.env}-${var.alb-type}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sec-grp.id]
  subnets            = var.subnets

  tags = {
    Environment = "${var.env}-${var.alb-type}"
  }
}

resource "aws_route53_record" "route53" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = 10
  records = [aws_lb.alb.dns_name]
}

#resource "aws_lb_listener" "listener-http-public" {
#  load_balancer_arn = aws_lb.alb.arn
#  port              = "80"
#  protocol          = "HTTP"
#
#  default_action {
#    type = "redirect"
#
#    redirect {
#      port        = "443"
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}
#
resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = var.tg_arn
  }
}