resource "aws_security_group" "sec-grp" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = var.app-port
    to_port          = var.app-port
    protocol         = "tcp"
    cidr_blocks      = var.vpc_cidr
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.workstation_node_cidr
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

resource "aws_launch_template" "template" {
  name = "${var.env}-${var.component}"
  image_id = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sec-grp.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-${var.component}"
    }
  }
  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
    role_name = var.component
    env = var.env
  }))
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.env}-${var.component}"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}