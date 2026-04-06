output "vm_private_ip" {
    description = "The private IP address of the workload VM"
    value = azurerm_network_interface.vm_nic.private_ip_address
}

output "resource_group_name" {
    description = "The name of the resource group"
    value = azurerm_resource_group.rg.name
}

output "bastion_public_ip" {
    description = "The public IP address of Azure Bastion"
    value = azurerm_public_ip.bastion_pip.ip_address
}