# the actual configuration of various values will be determined here

variable "region-oh" {
  default     = "us-east-2"
  description = "the region in which you will deploy your resources"
}

variable "availability-zone" {
  default     = "us-east-2a"
  description = "the AZ in which you'll deploy your stuff"
}

variable "vpc_cidr_block" {
  description = "the CIDR for our VPC"
  default     = "10.16.0.0/16"
}

variable "web_vpc_name" {
  default     = "WEB-VPC"
  description = "name of the VPC for our server"
}

variable "web_igw_name" {
  default     = "WEB-IGW"
  description = "name of the IGW"
}

variable "web_subnet_cidr" {
  default     = "10.16.1.0/24"
  description = "subnet CIDR"
}

variable "web_subnet_name" {
  default     = "web-subnet"
  description = "subnet name"
}

variable "subnet_map_public" {
  default     = true
  description = "boolean, map public or private IP"
}

variable "rt-cidr" {
  default     = "0.0.0.0/0"
  description = "CIDR for the public RT"
}

variable "rt-name" {
  default     = "public-rt"
  description = "name for the route table"

}


variable "sg-name" {
  default = "web-sg"

}

variable "http-port" {
  default = 80

}

variable "http-protocol" {
  default = "tcp"

}

variable "sg-ipv4-cidr" {
  default = "0.0.0.0/0"

}

variable "sg-ipv6-cidr" {
  default = "::/0"

}

variable "egress-port" {
  default = 0

}

variable "egress-protocol" {
  default = "-1"

}

variable "instance-type" {
  default = "t2.micro"

}

variable "ami-name" {
  default = "ami-06d4b7182ac3480fa"

}

variable "ingress-ssh-port" {
  default = 22

}

variable "ssh-protocol" {
  default = "tcp"

}

variable "ingress-ssh-cidr" {
  default = "3.16.146.0/29" # this cidr is for us-east-2 only

}

variable "nacl-ingress-protocol" {
  default = "-1"

}

variable "nacl-ingrees-port" {
  default = 0
}

variable "nacl-ingress-cidr" {
  default = "0.0.0.0/0"

}

variable "nacl-ingress-action" {
  default = "allow"

}

variable "nacl-ingress-rule-no" {
  default = 100

}

variable "nacl-egress-protocol" {
  default = "-1"

}

variable "nacl-egress-port" {
  default = 0
}

variable "nacl-egress-cidr" {
  default = "0.0.0.0/0"

}

variable "nacl-egress-action" {
  default = "allow"

}

variable "nacl-egress-rule-no" {
  default = 100

}

variable "launch-template-name" {
  default     = "apache-lt"
  description = "name of the launch template we're using"

}

variable "desired-capacity" {
  default     = 2
  description = "desired capacity of our ASG"
}

variable "max-size" {
  default     = 4
  description = "max size of our ASG"
}

variable "min-size" {
  default     = 1
  description = "min size of our ASG"
}

