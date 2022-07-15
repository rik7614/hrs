module "vpc" {
  source = "./module/vpc"
  cidr_range = "10.0.0.0/16"
  domain_name = "hrs.com"
  number_of_ngw = 2
  azs = ["us-west-2a, us-west-2b, us-west-2c"]
  public_cidr_ranges = ["172.18.0.0/22","172.18.4.0/22","172.18.8.0/22"]
  private_cidr_ranges= ["10.192.0.0/18","10.192.64.0/18","10.192.128.0/18"]
}
