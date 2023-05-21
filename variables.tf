
variable "region" {
  description = "AWS region for hosting our your network"
  default     = "ap-south-1"
}

variable "ami" {
  description = "image name"
  default     = "ami-02eb7a4783e7e9317"
}

variable "instance" {
 description = "instance type"
 default     = "t2.micro"
}

variable "instance_name" {
 description = "instance name"
 default     = "parent"
}

