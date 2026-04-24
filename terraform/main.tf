# =============================================
# main.tf
# Author: Surya
# Description: Core infrastructure for
#              Project 2 - Microservices on AKS
# =============================================

# =============================================
# RESOURCE GROUP
# =============================================
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    owner       = "Surya"
  }
}

# =============================================
# VIRTUAL NETWORK
# =============================================
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]

  tags = azurerm_resource_group.main.tags
}

# =============================================
# SUBNET FOR AKS
# =============================================
resource "azurerm_subnet" "aks" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# =============================================
# AZURE CONTAINER REGISTRY (ACR)
# Stores our Docker images
# =============================================
resource "azurerm_container_registry" "main" {
  name = "acr${var.project_name}${var.environment}${substr(md5(var.resource_group_name), 0, 6)}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = azurerm_resource_group.main.tags
}

# =============================================
# AKS CLUSTER
# Runs our microservices
# =============================================
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.project_name}-${var.environment}"

  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_size
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  # Use Managed Identity — no credentials needed!
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  tags = azurerm_resource_group.main.tags
}

# =============================================
# GIVE AKS PERMISSION TO PULL FROM ACR
# This is the industry standard way —
# no passwords, just Azure RBAC
# =============================================
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

# =============================================
# KEY VAULT
# Stores all secrets securely
# =============================================
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name = "kv-${var.project_name}-${substr(md5(var.resource_group_name), 0, 6)}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Only allow your own IP — security best practice
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }

  tags = azurerm_resource_group.main.tags
}