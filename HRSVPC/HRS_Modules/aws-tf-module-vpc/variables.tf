variable cidr_range {
  description = "CIDR range for the VPC"
  type        = string
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
  default     = null
}

variable "build_igw" {
  description = "Whether or not to build an internet gateway.  If disabled, no public subnets or route tables, internet gateway, or NAT Gateways will be created."
  type        = bool
  default     = true
}

variable "number_of_ngw" {
  description = "number of ngw"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to utilize for the subnets"
  type        = number
  default     = 3
}

variable "azs" {
  description = "availability zones"
  type        = list(string)
}

variable "public_cidr_ranges" {
  description = "An array of CIDR ranges to use for public subnets"
  type        = list(string)
  
}

variable "private_cidr_ranges" {
  description = "An array of CIDR ranges to use for private subnets"
  type        = list(string)
}

variable "public_subnets_per_az" {
  description = <<EOF
Number of public subnets to create in each AZ. NOTE: This value, when multiplied by the value of `az_count`,
should not exceed the length of the `public_cidr_ranges` list!
EOF

  type    = number
  default = 1
}

variable "private_subnets_per_az" {
  description = <<EOF
Number of private subnets to create in each AZ. NOTE: This value, when multiplied by the value of `az_count`,
should not exceed the length of the `private_cidr_ranges` list!
EOF

  type    = number
  default = 1
}

variable "build_nat_gateways" {
  description = "Whether or not to build a NAT gateway per AZ.  if `build_igw` is set to false, this value is ignored."
  type        = bool
  default     = true
}

variable "build_s3_flow_logs" {
  description = "Whether or not to build flow log components in s3"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "Bucket name to store s3 flow logs. If empty, a random bucket name is generated. Use in conjuction with `build_s3_flow_logs`"
  type        = string
  default     = ""
}

variable "logging_bucket_force_destroy" {
  description = "Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true"
  type        = bool
  default     = false
}

variable "logging_bucket_encryption_kms_mster_key" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms."
  type        = string
  default     = ""
}

variable "logging_bucket_encryption" {
  description = "Enable default bucket encryption. i.e. AES256 or aws:kms"
  type        = string
  default     = "aws:kms"
}

variable "logging_bucket_prefix" {
  description = "The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket."
  type        = string
  default     = ""
}

variable "s3_flowlog_retention" {
  description = "The number of days to retain flowlogs in s3. A value of `0` will retain indefinitely."
  type        = number
  default     = 14
}

variable "build_flow_logs" {
  description = "Whether or not to build flow log components in Cloudwatch Logs"
  default     = true
  type        = bool
}

variable "cloudwatch_flowlog_retention" {
  description = "The number of days to retain flowlogs in CLoudwatch Logs. Valid values are: [0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653]. A value of `0` will retain indefinitely."
  type        = number
  default     = 14
}

variable "logging_bucket_access_control" {
  description = "Define ACL for Bucket from one of the [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl): private, public-read, public-read-write, aws-exec-read, authenticated-read, log-delivery-write"
  type        = string
  default     = "private"
}

variable "env" {
  description = "Application environment for which this network is being created. e.g. Development/Production"
  type        = string
}

variable "env_naming" {
  description = "Application environment for which this network is being created. e.g. Development/Production"
  type        = string
}
variable "tags" {
  description = "Optional tags to be applied on top of the base tags on all resources"
  type        = map(string)
  default     = {}
}

variable "single_nat" {
  description = "Deploy VPC in single NAT mode."
  type        = bool
  default     = false
}

variable "admin_email" {
  description = "Contact email of the administrator of this AWS component"
  type        = string
  default     = "administrator-txs@hrs.com"
}

variable "application" {
  description = "The short and unique name of an application or service"
  type        = string
}

variable "environment_group" {
  description = "Groups a set of resources which build up an environment containing many applications and infrastructure elements"
  type        = string
  default     = null
}

variable "repo_url" {
  description = "Tag that points to the source code repository url which allows you to find the code that was used to create the resource in question"
  type        = string
  default     = "https://gitlab.shec.cdi.hrs.cc/rackspace/rackspace"
}

variable "jira_number" {
  description = "Where a request/change for resources is coming / created from. When changes can not track"
  type        = string
  default     = null
}

variable "administrator_sns" {
  description = "If you want to also receive messages from custodian policy to SNS topic provide it here"
  type        = string
  default     = null
}

variable "component" {
  description = "Denotes the component or component type of an application. Compare to the Server Naming Concept"
  type        = string
  default     = null
}

variable "tier" {
  description = "The tier a subnet is used for, see VPC, Subnet, and Stack Architecture"
  type        = string
  default     = null
}

variable "Version" {
  description = "Version of an application. Used to check out a tag from Git"
  type        = string
  default     = null
}

variable "site" {
  description = "Globally unique value for a data center site / AWS VPC"
  type        = string
  default     = null
}

variable "security_class" {
  description = "Security Classification of a resource security severity level"
  type        = string
  default     = null
}

variable "cluster" {
  description = "Multiple Resources that belong to the same Kubernetes cluster can share the same tag"
  type        = string
  default     = null
}

variable "schedular" {
  description = "AWS Instance Shutdown Scheduling Policy"
  type        = string
  default     = null
}

variable "owner" {
  description = "Name of the team which is responsiable for this resource"
  type        = string
  default     = null
}

variable "creator" {
  description = "Email address of the person who created this resource. Mandatory for all manually created resources. Will be used to notify creator by custodian policies"
  type        = string
  default     = "Rikesh.ManDangol@rackspace.co.uk"
}

variable "backup" {
  description = "AWS ec2 backup"
  type        = string
  default     = null
}


variable "cost_center" {
  description = "Cost center of a product / team."
  type        = string
  default     = null
}

variable "data_class" {
  description = "Cost center of a product / team."
  type        = string
  default     = null
}

variable "primary_subnet_type" {
  description = "primary subnet"
  type        = string
  default     = "public"
}

variable "secondary_subnet_type" {
  description = "secondary subnet"
  type        = string
  default     = "private"
}

variable "public_subnet_tags" {
  description = "A list of maps containing tags to be applied to public subnets. List should either be the same length as the number of AZs to apply different tags per set of subnets, or a length of 1 to apply the same tags across all public subnets."
  type        = list(map(string))

  default = [{}]
}

variable "public_subnet_names" {
  description = <<EOF
Text that will be included in generated name for public subnets. Given the default value of `["Public"]`, subnet
names in the form \"<vpc_name>-Public<count+1>\", e.g. \"MyVpc-Public1\" will be produced. Otherwise, given a
list of names with length the same as the value of `az_count`, the first `az_count` subnets will be named using
the first string in the list, the second `az_count` subnets will be named using the second string, and so on.
EOF

  type    = list(string)
  default = ["Public"]
}


variable "private_subnet_tags" {
  description = "A list of maps containing tags to be applied to private subnets. List should either be the same length as the number of AZs to apply different tags per set of subnets, or a length of 1 to apply the same tags across all private subnets."
  type        = list(map(string))

  default = [{}]
}

variable "private_subnet_names" {
  description = <<EOF
Text that will be included in generated name for private subnets. Given the default value of `["Private"]`, subnet
names in the form \"<vpc_name>-Private<count+1>\", e.g. \"MyVpc-Public2\" will be produced. Otherwise, given a
list of names with length the same as the value of `az_count`, the first `az_count` subnets will be named using
the first string in the list, the second `az_count` subnets will be named using the second string, and so on.
EOF

  type    = list(string)
  default = ["Private"]
}