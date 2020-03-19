variable "region" {
  type        = string
  description = "Region where the AWS resources will live."
}

variable "stack_name" {
  type        = string
  description = "Friendly name for the stack."
}

variable "app_subnet_a_id" {
  type        = string
  description = "AWS Subnet A ID for app tier."
}

variable "app_subnet_b_id" {
  type        = string
  description = "AWS Subnet B ID for app tier."
}

variable "web_subnet_a_id" {
  type        = string
  description = "AWS Subnet A ID for web tier."
}

variable "web_subnet_b_id" {
  type        = string
  description = "AWS Subnet B ID for app tier."
}