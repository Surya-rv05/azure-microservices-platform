# =============================================
# providers.tf
# Author: Surya
# Description: Configure Azure provider for
#              Terraform
# =============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Store Terraform state in Azure Blob Storage
  # This is industry standard — never store state locally
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterrastate123"
    container_name       = "tfstate"
    key                  = "project2.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}