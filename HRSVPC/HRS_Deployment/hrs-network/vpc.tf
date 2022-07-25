module "vpc" {
  source              = "../../HRS_Modules/aws-tf-module-vpc"
  cidr_range          = var.vpc_cidr
  number_of_ngw       = 3
  azs                 = var.azs
  public_cidr_ranges  = var.public_cidr_ranges
  private_cidr_ranges = var.private_cidr_ranges
  env                 = var.env
  application         = var.application
  env_naming          = var.env_naming

}