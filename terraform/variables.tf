# =============================================
# variables.tf
# Author: Surya
# Description: Input variables for Project 2
#              infrastructure
# =============================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-project2-dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralindia"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "microservices"
}

variable "aks_node_count" {
  description = "Number of nodes in AKS cluster"
  type        = number
  default     = 1  # Keep at 1 to save credit!
}

variable "aks_node_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s_v2"
}