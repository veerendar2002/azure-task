terraform {
  backend "azurerm" {
    resource_group_name  = "rg-devops-tfstate"
    storage_account_name = "tfstateveeru2026"
    container_name       = "tfstate"
    key                  = "azure-task.tfstate"

    use_azuread_auth = true
  }
}