terraform {
  backend "azurerm" {
    resource_group_name  = "t-clo-901-nts-0"
    storage_account_name = "atclo901nts03632"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}