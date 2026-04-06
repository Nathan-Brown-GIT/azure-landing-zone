variable "location" {
  description = "The Azure region to deploy resources into"
  type = string
  default = "ukwest"
}

variable "resource_group_name" {
    description = "The name of the resource group"
    type = string
    default = "rg-landing-zone-prod"
}

variable "hub_vnet_name" {
    description = "The name of the hub virtual network"
    type = string
    default ="vnet-hub-prod"
}

variable "hub_vnet_address_space" {
    description = "The address space for the hub vnet"
    type = list(string)
    default = ["10.0.0.0/16"]
}

variable "spoke_vnet_name" {
    description = "The name of the spoke virtual network"
    type = string
    default = "vnet-spoke-prod"
}

variable "spoke_vnet_address_space" {
    description = "The address space for the spoke VNet"
    type = list(string)
    default = ["10.1.0.0/16"]
}

variable "vm_admin_username" {
    description = "The Admin username for the VM"
    type = string
    default = "azureuser"
}

variable "vm_admin_password" {
    description = "The Admin password for the VM."
    type = string
    sensitive = true
}



