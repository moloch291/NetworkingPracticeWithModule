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

variable "subnet_numbers" {
    type        = map(number)
    description = "Map of AZs to a number that should be used for public subnets"

    default = {
        "${var.region}a" = 1
        "${var.region}b" = 2
        "${var.region}c" = 3
    }
}