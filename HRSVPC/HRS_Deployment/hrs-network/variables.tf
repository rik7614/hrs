variable "region" {
  type    = string
  default = "eu-central-1"
}
variable "env" {
  type    = string
  default = "prod"
}
variable "env_naming" {
  type    = string
  default = "pec"
}

variable "application" {
  type        = string
  description = "Application name"
  default     = "network"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
}

variable "public_cidr_ranges" {
  type        = list(any)
  description = "CIDR for public subnet"
}
variable "private_cidr_ranges" {
  type        = list(any)
  description = "CIDR for private subnet"
}

variable "azs" {
  type        = list(any)
  description = "Avalibality Zone"
}                                              