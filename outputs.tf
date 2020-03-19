output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_subnet_a_id" {
  value = aws_subnet.app_subnet_a.id
}

output "app_subnet_b_id" {
  value = aws_subnet.app_subnet_b.id
}

output "web_subnet_a_id" {
  value = aws_subnet.web_subnet_a.id
}

output "web_subnet_b_id" {
  value = aws_subnet.web_subnet_b.id
}