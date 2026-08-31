variable "prefix" {
  description = "Prefix used for Azure resource names"
  type        = string
  default     = "veerudemo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "vnet_cidr" {
  description = "VNet address space"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet address space"
  type        = string
  default     = "10.10.1.0/24"
}

variable "app_subnet_cidr" {
  description = "Private App subnet address space"
  type        = string
  default     = "10.10.2.0/24"
}

variable "pe_subnet_cidr" {
  description = "Private Endpoint subnet address space"
  type        = string
  default     = "10.10.3.0/24"
}

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "sql_sku" {
  description = "Azure SQL Database SKU"
  type        = string
  default     = "Basic"
}

variable "sql_admin_username" {
  description = "SQL administrator username"
  type        = string
  default     = "sqladminuser"
}

variable "tags" {
  type = map(string)

  default = {
    project    = "azure-task"
    owner      = "veerendar"
    managed_by = "terraform"
  }
}