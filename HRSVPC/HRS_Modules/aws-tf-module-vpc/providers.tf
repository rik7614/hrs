terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63"
    }
  }
}

locals {
  base_tags = {
    AdministratorEmail  = var.admin_email
    Environment         = var.env
    Application         = var.application
    EnvironmentGroup    = var.environment_group
    RepoURL             = var.repo_url
    JIRA                = var.jira_number
    CreatedUsing        = "terraform"
    AdministratorSNS    = var.administrator_sns
    component           = var.component
    Tier                = var.tier
    Version             = var.Version
    Scheduler           = var.schedular
    Creator             = var.creator
    Backup              = var.backup
    Cluster             = var.cluster
    SecurityClass       = var.security_class
    Owner               = var.owner
    CostCenter          = var.cost_center
    DataClass           = var.data_class
    Site                = var.site
  }
    subnet_tag          = ["a", "b", "c"]   
}