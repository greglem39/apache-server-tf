# output "web-instance-ip" {
#   value = aws_instance.web-instance.public_ip

# }

output "lt-arn" {
  value = aws_launch_template.web-server-lt.arn

}

output "asg-arn" {
  value = aws_autoscaling_group.web-server-asg.arn

}
