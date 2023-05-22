## creating a vpc in aws

resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    tags = {
        Name = "terraform-vpc"
    }
}

### Create Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}
 
# Create Subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true"
}

# Create Subnet2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "true"
}

# Create Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}


#### creating aws key pair

resource "aws_key_pair" "tera" {
  key_name   = "tera"
  public_key = tls_private_key.key-gen.public_key_openssh
}

resource "tls_private_key" "key-gen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tera" {
  content   = tls_private_key.key-gen.private_key_pem
  filename  = "tera"

}

### creating launch configuration

# Create Launch Configuration
resource "aws_launch_configuration" "lc" {
  name                 = var.instance_name
  image_id             = var.ami
  instance_type        = var.instance

  security_groups      = [aws_security_group.sg.id]
  user_data            = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
}


### creating auto-scaling group

resource "aws_autoscaling_group" "asg" {
  name                 = "example-autoscaling-group"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.lc.name
  vpc_zone_identifier  = [aws_subnet.subnet.id,aws_subnet.subnet2.id]
  tags = [
    {
      key                 = "Name"
      value               = var.instance_name
      propagate_at_launch = true
    },
  ]
}

# Create Security Group
resource "aws_security_group" "sg" {
  name        = "secure-security-group"
  description = "security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["192.168.1.30/32"]
  }
  ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["192.168.1.30/32"]
    }
  ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["192.168.1.30/32"]
    }
  egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
  }
}

