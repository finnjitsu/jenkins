/*******************************************************************************
*                                                                              *
* Security groups                                                              *
*                                                                              *
*******************************************************************************/

resource "aws_security_group" "jenkins_frontend" {
  name        = "${var.stack_name}-jenkins-frontend-sg"
  description = "Allow https into load balancer for Jenkins."
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    ipv6_cidr_blocks = [
      "::/0"
    ]
  }
}

resource "aws_security_group" "jenkins_egress" {
  name        = "${var.stack_name}-jenkins-egress-sg"
  description = "Allow traffic out from Jenkins server."
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    ipv6_cidr_blocks = [
      "::/0"
    ]
  }
}

resource "aws_security_group" "jenkins_lb_sg" {
  name        = "${var.stack_name}-jenkins-lb-sg"
  description = "Allow traffic between Jenkins server and load balancer."
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    self            = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
   self        = true
  }
}

/*******************************************************************************
*                                                                              *
* EC2 Instances                                                                *
*                                                                              *
*******************************************************************************/

data "aws_ami" "amzn2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = [ "amzn2-ami-hvm-2*" ]
  }

  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }

  owners = [ "137112412989" ] # Amazon

}

resource "aws_instance" "jenkins_01" {
  ami                    = data.aws_ami.amzn2.id
  instance_type          = var.ec2_instance_type
  availability_zone      = "${var.region}a"
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name
  subnet_id              = var.app_subnet_a_id
  user_data              = templatefile("${path.module}/user-data.tpl", {})
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      user_data,
      root_block_device,
      ami
      ]
  } 
  root_block_device {
    volume_size = var.root_disk_sz
    volume_type = "gp2"
    encrypted   = true
  }
  vpc_security_group_ids = [
    aws_security_group.jenkins_lb_sg.id,
    aws_security_group.jenkins_egress.id
  ]
  tags = {
    Name = "${var.stack_name}-jenkins-01"
  }
}

/*******************************************************************************
*                                                                              *
* Block Storage                                                                *
*                                                                              *
*******************************************************************************/

/*resource "aws_ebs_volume" "jenkins_01_app_01" {
  availability_zone  = "${var.region}a"
  size               = var.app_disk_sz
  type               = "gp2"
  encrypted          = true
  tags = {
    Name = "${var.stack_name}-jenkins-01-app-01"
  }
}

resource "aws_volume_attachment" "jenkins_01_app_volume_attachment_01" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.jenkins_01_app_01.id
  instance_id = aws_instance.jenkins_01.id
}*/

/*******************************************************************************
*                                                                              *
* Load Balancers                                                               *
*                                                                              *
*******************************************************************************/

/*resource "aws_lb" "jenkins_alb" {
  name                      = "${var.stack_name}-jenkins-alb"
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [
    var.web_subnet_a_id,
    var.web_subnet_b_id
  ]
  security_groups           = [
    aws_security_group.jenkins_frontend.id,
    aws_security_group.jenkins_lb_sg.id
  ] 
  access_logs {
    bucket  = aws_s3_bucket.jenkins.id
    prefix  = "AWS"
    enabled = true
  }
  tags = { 
    Name = "${var.stack_name}-jenkins-alb"
  }
}

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "${var.stack_name}-jenkins-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path    = "/login/?next=/welcome/"
    matcher = "200,302"
  }
  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_lb_target_group_attachment" "jenkins_tg_att_01" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins_01.id
  port             = 80
}*/