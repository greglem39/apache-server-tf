output "web-instance-ip" {
  value = aws_instance.web-instance.public_ip

}

output "lt-name" {
  value = aws_launch_template.web-server-lt.arn

}
