data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "${var.prefix}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled = true

  soft_delete_retention_days = 90

  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  name         = "AppInsights-ConnectionString"
  value        = var.app_insights_connection_string
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.deployer_secrets_officer
  ]
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "Sql-ConnectionString"
  value        = var.sql_connection_string
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.deployer_secrets_officer
  ]
}

resource "azurerm_role_assignment" "app_service_secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_service_principal_id
}

resource "azurerm_role_assignment" "deployer_secrets_officer" {
  count = var.deployer_principal_id != "" ? 1 : 0

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.deployer_principal_id
}