/*******************************************************************************
*                                                                              *
* Security groups                                                              *
*                                                                              *
*******************************************************************************/

resource "aws_security_group" "jenkins_frontend" {
  name        = "jenkins-frontend-sg"
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
  name        = "jenkins-egress-sg"
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
  name        = "jenkins-lb-sg"
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

data "template_file" "jenkins_init" {
  template = file("./user-data.tpl")
  vars = {
    branch                 = var.repo_branch
    environment            = var.environment
  }
}

resource "aws_instance" "jenkins_01" {

  ami                    = data.aws_ami.amzn2.id
  instance_type          = var.ec2_instance_type
  availability_zone      = var.az_node_01
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name
  subnet_id              = var.int_subnet_id_01
  user_data              = data.template_file.jenkins_init.rendered
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
    aws_security_group.alation_data_catalog_lb_sg.id,
    aws_security_group.alation_data_catalog_egress_sg.id
  ]
  tags = {
    Name               = "${var.environment}-alation-data-catalog-01"
    Environment        = var.environment
    CreatorOwner       = "Greg Snarr"
    CostCenter         = "${var.cost_center}"
    Product            = "Data Lake"
    Productcode        = "18-089"
    Projectcode        = "18-089"
    Team               = "Data Services "
    Role               = "App/Database"
    Application        = "Alation Data Catalog"
    DeploymentMethod   = "Terraform"
    ScheduledDowntime  = var.scheduled_downtime
    StopSchedule       = "cron(${var.stop_schedule})"
    StartSchedule      = "cron(${var.start_schedule})"
  }
}

/*******************************************************************************
*                                                                              *
* Block Storage                                                                *
*                                                                              *
*******************************************************************************/

resource "aws_ebs_volume" "alation_data_catalog_01_app_01" {
  availability_zone  = var.az_node_01
  size               = var.app_disk_sz
  type               = "gp2"
  encrypted          = true
  tags = {
    Name             = "${var.environment}-alation-data-catalog-01-app-01"
    Environment      = var.environment
    CreatorOwner     = "Greg Snarr"
    CostCenter       = "${var.cost_center}"
    Product          = "Data Lake"
    Productcode      = "18-089"
    Projectcode      = "18-089"
    Team             = "Data Services "
    Role             = "App"
    Application      = "Alation Data Catalog"
    DeploymentMethod = "Terraform"
  }
}

resource "aws_ebs_volume" "alation_data_catalog_01_data_01" {
  availability_zone  = var.az_node_01
  size               = var.data_disk_sz
  type               = "gp2"
  encrypted          = true
  tags = {
    Name             = "${var.environment}-alation-data-catalog-01-data-01"
    Environment      = var.environment
    CreatorOwner     = "Greg Snarr"
    CostCenter       = "${var.cost_center}"
    Product          = "Data Lake"
    Productcode      = "18-089"
    Projectcode      = "18-089"
    Team             = "Data Services "
    Role             = "Database"
    Application      = "Alation Data Catalog"
    DeploymentMethod = "Terraform"
  }
}

resource "aws_ebs_volume" "alation_data_catalog_01_bkp_01" {
  availability_zone  = var.az_node_01
  size               = var.bkp_disk_sz
  type               = "gp2"
  encrypted          = true
  tags = {
    Name             = "${var.environment}-alation-data-catalog-01-bkp-01"
    Environment      = var.environment
    CreatorOwner     = "Greg Snarr"
    CostCenter       = "${var.cost_center}"
    Product          = "Data Lake"
    Productcode      = "18-089"
    Projectcode      = "18-089"
    Team             = "Data Services "
    Role             = "Backup"
    Application      = "Alation Data Catalog"
    DeploymentMethod = "Terraform"
  }
}

resource "aws_volume_attachment" "alation_data_catalog_01_app_volume_attachment_01" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.alation_data_catalog_01_app_01.id
  instance_id = aws_instance.alation_data_catalog_01.id
}

resource "aws_volume_attachment" "alation_data_catalog_01_data_volume_attachment_01" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.alation_data_catalog_01_data_01.id
  instance_id = aws_instance.alation_data_catalog_01.id
}

resource "aws_volume_attachment" "alation_data_catalog_01_bkp_volume_attachment_01" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.alation_data_catalog_01_bkp_01.id
  instance_id = aws_instance.alation_data_catalog_01.id
}

/*******************************************************************************
*                                                                              *
* Load Balancers                                                               *
*                                                                              *
*******************************************************************************/

resource "aws_lb" "alation_data_catalog_alb" {
  name                      = "${var.environment}-alation-ext-alb"
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [
    var.ext_subnet_id_01,
    var.ext_subnet_id_02
  ]
  security_groups           = [
    aws_security_group.alation_data_catalog_frontend_sg.id,
    aws_security_group.alation_data_catalog_lb_sg.id
  ] 
  access_logs {
    bucket  = aws_s3_bucket.alation_bucket.id
    prefix  = "AWS"
    enabled = true
  }
  tags = { 
    Name             = "${var.environment}-alation-data-catalalog-ext-alb"
    Environment      = var.environment
    CreatorOwner     = "Greg Snarr"
    CostCenter       = "${var.cost_center}"
    Product          = "Data Lake"
    Productcode      = "18-089"
    Projectcode      = "18-089"
    Team             = "Data Services "
    Role             = "App"
    Application      = "Alation Data Catalog"
    DeploymentMethod = "Terraform"
  }
}

resource "aws_lb_listener" "alation_data_catalog_listener" {
  load_balancer_arn = aws_lb.alation_data_catalog_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alation_data_catalog_tg.arn
  }
}

resource "aws_lb_target_group" "alation_data_catalog_tg" {
  name     = "${var.environment}-alation-data-catalog-tg"
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

resource "aws_lb_target_group_attachment" "alation_data_catalog_tg_att_01" {
  target_group_arn = aws_lb_target_group.alation_data_catalog_tg.arn
  target_id        = aws_instance.alation_data_catalog_01.id
  port             = 80
}