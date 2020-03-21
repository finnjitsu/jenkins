variable "region" {
  type        = string
  description = "Region where the AWS resources will live."
}

variable "stack_name" {
  type        = string
  description = "Friendly name for the stack."
}

variable "ec2_instance_type" {
  type        = string
  description = "Type of EC2 instance where the jenkins software will run."
}

variable "root_disk_sz" {
  type        = string
  description = "How big should the root disk be?"
}

variable "app_disk_sz" {
  type        = string
  description = "How big should the app disk be?"
}

variable "vpc_id" {
  type        = string
  description = "VPC where the stack will live."
}

variable "app_subnet_a_id" {
  type        = string
  description = "Subnet ID for the first app teir subnet."
}

variable "app_subnet_b_id" {
  type        = string
  description = "Subnet ID for the second app teir subnet."
}

variable "web_subnet_a_id" {
  type        = string
  description = "Subnet ID for the first web teir subnet."
}

variable "web_subnet_b_id" {
  type        = string
  description = "Subnet ID for the second web teir subnet."
}

variable "aws_lb_account_id" {
  type        = string
  default     = "127311923021"
  description = "AWS Account from which load balancer access logs originate."
}