# the goal of this project is to create and automate the provisioning of an apache web server

# create vpc for our server
resource "aws_vpc" "web-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.web_vpc_name
  }
}

# create Internet Gateway to allow traffic into VPC
resource "aws_internet_gateway" "web-igw" {
  vpc_id = aws_vpc.web-vpc.id
  tags = {
    Name = var.web_igw_name
  }
}

# create subnet for the EC2 instance
resource "aws_subnet" "web-subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = var.web_subnet_cidr[count.index]
  availability_zone       = var.subnet_az[count.index]
  map_public_ip_on_launch = var.subnet_map_public
}

# need to create a second subnet, per ALB requirements

# # creating a route table for our subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.web-vpc.id
  route {
    cidr_block = var.rt-cidr
    gateway_id = aws_internet_gateway.web-igw.id
  }
  tags = {
    Name = var.rt-name
  }
}

# rt association
resource "aws_route_table_association" "public-rt-association" {
  count          = 2
  subnet_id      = aws_subnet.web-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

# network ACL
resource "aws_network_acl" "web-acl" {
  vpc_id     = aws_vpc.web-vpc.id
  subnet_ids = [for i in aws_subnet.web-subnet : i.id]
  # allow ingress all
  ingress {
    protocol   = var.nacl-ingress-protocol
    from_port  = var.nacl-ingrees-port
    to_port    = var.nacl-ingrees-port
    action     = var.nacl-ingress-action
    cidr_block = var.nacl-ingress-cidr
    rule_no    = var.nacl-ingress-rule-no
  }
  egress {
    protocol   = var.nacl-egress-protocol
    from_port  = var.nacl-egress-port
    to_port    = var.nacl-egress-port
    action     = var.nacl-egress-action
    cidr_block = var.nacl-egress-cidr
    rule_no    = var.nacl-egress-rule-no
  }
}

# resource "aws_default_subnet" "default_az1" { # this was for testing only
#   availability_zone = "us-east-2a"

#   tags = {
#     Name = "Default subnet for us-east-2a"
#   }
# }

# create a security group for SSH purposes 
resource "aws_security_group" "web-sg" {
  vpc_id = aws_vpc.web-vpc.id
  name   = var.sg-name
  ingress {
    description      = "HTTP connections allowed"
    from_port        = var.http-port
    to_port          = var.http-port
    protocol         = var.http-protocol
    cidr_blocks      = [var.sg-ipv4-cidr]
    ipv6_cidr_blocks = [var.sg-ipv6-cidr]
  }
  ingress {
    description      = "ssh connections allowed"
    from_port        = var.ingress-ssh-port
    to_port          = var.ingress-ssh-port
    protocol         = var.ssh-protocol
    cidr_blocks      = [var.ingress-ssh-cidr]
    ipv6_cidr_blocks = [var.sg-ipv6-cidr]
  }
  egress {
    description      = "egress"
    from_port        = var.egress-port
    to_port          = var.egress-port
    protocol         = var.egress-protocol
    cidr_blocks      = [var.sg-ipv4-cidr]
    ipv6_cidr_blocks = [var.sg-ipv6-cidr]
  }

  tags = {
    Name = "allow-http"
  }
}

# create Ec2 instance to test the creation of an Apache server
# resource "aws_instance" "web-instance" {
#   security_groups = [aws_security_group.web-sg.id]
#   subnet_id       = aws_subnet.web-subnet.id
#   ami             = var.ami-name
#   instance_type   = var.instance-type
#   user_data       = filebase64("install_apache.sh")
#   tags = {
#     Name = "web-instance-tf"
#   }
# }

# ==============================================================================================================
# UP TO THIS POINT HAS WORKED. FROM HERE, I AM ADDING A BIT OF AUTOSCALING FUNCTIONALITY TO EXPAND ON THE ABOVE. 
# ==============================================================================================================

# let's add an ALB or two and an ASG for a target 
# additionally, we'll be converting the EC2 instance into an LT to help with scaling

resource "aws_launch_template" "web-server-lt" {
  name = var.launch-template-name
  tags = {
    Name = var.launch-template-name
  }
  image_id      = var.ami-name
  instance_type = var.instance-type
  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.web-sg.id]
  }
  user_data = filebase64("install_apache.sh")
}

resource "aws_autoscaling_group" "web-server-asg" {
  desired_capacity    = var.desired-capacity
  min_size            = var.min-size
  max_size            = var.max-size
  vpc_zone_identifier = [for i in aws_subnet.web-subnet : i.id]
  target_group_arns   = [aws_alb_target_group.alb-target-group.arn]
  launch_template {
    id      = aws_launch_template.web-server-lt.id
    version = aws_launch_template.web-server-lt.latest_version
  }
}

resource "aws_alb" "web-alb" {
  name               = var.elb-name
  internal           = var.internal-elb
  load_balancer_type = var.elb-type
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [for i in aws_subnet.web-subnet : i.id]
}

resource "aws_alb_target_group" "alb-target-group" {
  name     = var.target-group-name
  port     = var.target-group-port
  protocol = var.target-group-protocol
  vpc_id   = aws_vpc.web-vpc.id
  health_check {
    path    = var.health-check-path
    matcher = var.health-check-matcher
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.web-alb.arn
  port              = var.alb-listener-port
  protocol          = var.alb-listner-protocol
  default_action {
    type             = var.action-type
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }
}
