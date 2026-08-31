# ============================================================
# ROOT MODULE
# Connects all Terraform child modules together
# ============================================================

# ------------------------------------------------------------
# 1. RESOURCE GROUP
# ------------------------------------------------------------

module "resource_group" {
  source = "./modules/resource_group"

  name     = "rg-devops-learning"
  location = var.location
  tags     = var.tags
}


# ------------------------------------------------------------
# 2. VIRTUAL NETWORK + 3 SUBNETS
# ------------------------------------------------------------

module "network" {
  source = "./modules/network"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  vnet_cidr          = var.vnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
  app_subnet_cidr    = var.app_subnet_cidr
  pe_subnet_cidr     = var.pe_subnet_cidr

  tags = var.tags
}


# ------------------------------------------------------------
# 3. APPLICATION INSIGHTS
# ------------------------------------------------------------

module "app_insights" {
  source = "./modules/app_insights"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = var.tags
}


# ------------------------------------------------------------
# 4. SQL DATABASE
# ------------------------------------------------------------

module "sql_database" {
  source = "./modules/sql_database"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  admin_username = var.sql_admin_username
  sku_name       = var.sql_sku

  tags = var.tags
}


# ------------------------------------------------------------
# 5. KEY VAULT NAME
# ------------------------------------------------------------

locals {
  key_vault_name = "${var.prefix}-kv"
  key_vault_uri  = "https://${local.key_vault_name}.vault.azure.net/"
}


# ------------------------------------------------------------
# 6. APP SERVICE
# ------------------------------------------------------------

module "app_service" {
  source = "./modules/app_service"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  app_subnet_id = module.network.app_subnet_id

  key_vault_uri = local.key_vault_uri

  sku_name     = var.app_service_sku
  node_version = "18-lts"

  tags = var.tags
}


# ------------------------------------------------------------
# 7. KEY VAULT
# ------------------------------------------------------------

module "key_vault" {
  source = "./modules/key_vault"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  # App Service Managed Identity
  app_service_principal_id = module.app_service.principal_id

  # Identity running Terraform/GitHub Actions
  deployer_principal_id = data.azurerm_client_config.current.object_id

  # Store Application Insights connection string in Key Vault
  app_insights_connection_string = module.app_insights.connection_string

  # Store SQL connection string in Key Vault
  sql_connection_string = module.sql_database.connection_string

  tags = var.tags
}


# ------------------------------------------------------------
# 8. KEY VAULT PRIVATE ENDPOINT
# ------------------------------------------------------------

module "key_vault_private_endpoint" {
  source = "./modules/private_endpoint"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  subnet_id = module.network.pe_subnet_id
  vnet_id   = module.network.vnet_id

  key_vault_id = module.key_vault.id

  tags = var.tags
}