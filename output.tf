# output "web-instance-ip" {
#   value = aws_instance.web-instance.public_ip

# }

output "alb-dns" {
  value = aws_alb.web-alb.dns_name
}
