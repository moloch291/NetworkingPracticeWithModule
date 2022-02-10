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