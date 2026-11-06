output "alb_url" {
  description = "Open this URL after targets become healthy"
  value       = "http://${aws_lb.alb.dns_name}"
}

output "instance_ids" {
  value = aws_instance.web[*].id
}

output "availability_zones" {
  value = aws_subnet.public[*].availability_zone
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
