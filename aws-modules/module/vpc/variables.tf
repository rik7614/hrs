variable "cidr_range" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "172.18.0.0/19"
}

variable "enable_dns_hostnames" {
  description = "Whether or not to enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether or not to enable DNS support for the VPC"
  type        = bool
  default     = true
}

variable "default_tenancy" {
  description = "Default tenancy for instances. Either multi-tenant (default) or single-tenant (dedicated)"
  type        = string
  default     = "default"
}

variable "domain_name_servers" {
  description = "Array of custom domain name servers"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "enable_dhcp_options" {
  description = "DHCP Options"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "build_igw" {
  description = "Whether or not to build an internet gateway.  If disabled, no public subnets or route tables, internet gateway, or NAT Gateways will be created."
  type        = bool
  default     = true
}

variable "number_of_ngw" {
  description = "number of ngw"
  type        = string
  default     = 1
}

variable "az_count" {
  description = "Number of AZs to utilize for the subnets"
  type        = number
  default     = 2
}

variable "azs" {
  description = "availability zones"
  type        = list(string)
  default     = ["us-west-2a, us-west-2b, us-west-2c, us-west-2d"]

}

variable "public_cidr_ranges" {
  description = "An array of CIDR ranges to use for public subnets"
  type        = list(string)
  default     = ["172.18.0.0/22","172.18.4.0/22","172.18.8.0/22"]
}

variable "private_cidr_ranges" {
  description = "An array of CIDR ranges to use for private subnets"
  type        = list(string)
  default     = ["10.192.0.0/18","10.192.64.0/18","10.192.128.0/18"]
}

variable "build_nat_gateways" {
  description = "Whether or not to build a NAT gateway per AZ.  if `build_igw` is set to false, this value is ignored."
  type        = bool
  default     = true
}