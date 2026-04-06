resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "hub" {
    name = var.hub_vnet_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = var.hub_vnet_address_space
}

resource "azurerm_subnet" "bastion_subnet" {
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub.name
    address_prefixes = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "management_subnet" {
    name = "snet-management"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub.name
    address_prefixes = ["10.0.2.0/24"]
}    

resource "azurerm_virtual_network" "spoke" {
    name = var.spoke_vnet_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = var.spoke_vnet_address_space
}

resource "azurerm_subnet" "workload_subnet" {
    name = "snet-workload"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.spoke.name
    address_prefixes = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke"{
    name = "peer-hub-to-spoke"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub.name
    remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
    name = "peer-spoke-to-hub"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.spoke.name
    remote_virtual_network_id = azurerm_virtual_network.hub.id
    allow_virtual_network_access = true
}

resource "azurerm_network_security_group" "workload_nsg" {
    name = "nsg-workload-prod"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name = "Allow-SSH-From-Hub"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "10.0.0.0/16"
        destination_address_prefix = "10.1.1.0/24"
    }

    security_rule {
        name = "Deny-All-Inbound"
        priority = "4000"
        direction = "Inbound"
        access = "Deny"
        protocol = "*"
        source_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
        destination_port_range = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "workload_nsg_assoc"{
    subnet_id = azurerm_subnet.workload_subnet.id
    network_security_group_id = azurerm_network_security_group.workload_nsg.id
}

resource "azurerm_public_ip" "bastion_pip" {
    name = "pip-bastion-prod"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
    name = "bastion-hub-prod"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "bastion-ip-config"
        subnet_id = azurerm_subnet.bastion_subnet.id
        public_ip_address_id = azurerm_public_ip.bastion_pip.id
    }
}

resource "azurerm_network_interface" "vm_nic" {
    name = "nic-vm-workload-prod"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "vm-ip-config"
        subnet_id = azurerm_subnet.workload_subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = "vm-workload-prod"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_B1s"
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password
    disable_password_authentication = false
    network_interface_ids = [azurerm_network_interface.vm_nic.id]

    os_disk {
        storage_account_type = "Standard_LRS"
        caching = "ReadWrite"
    }

    source_image_reference {
        publisher ="Canonical"
        offer ="ubuntu-24_04-lts"
        sku = "server"
        version = "latest"
    }
}
