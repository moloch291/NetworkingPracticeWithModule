variable "env" {
  type        = string
  description = "Name of the environment"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "IP range of the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  type    = number
  default = 3 # Should be defined as 1, 2 or 3
}

variable "private_subnet_count" {
  type    = number
  default = 3 # Should be defined as 1, 2 or 3
}