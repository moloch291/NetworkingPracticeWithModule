variable "env" {
    type        = string
    description = "Name of the environment"
    default     = "dev"
}

variable "region" {
    type        = string
    description = "Region for to VPC"
    default     = "eu-central-1"
}

variable "vpc_cidr" {
    type        = string
    description = "IP range of the VPC"
    default     = "10.0.0.0/16"
}

variable "subnet_numbers" {
    type        = map(number)
    description = "Map of AZ to a number that should be used for public subnets"

    default = {
        "eu-central-1a" = 1
        "eu-central-1b" = 2
        "eu-central-1c" = 3
    }
}