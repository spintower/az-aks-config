# Create security group
resource "azurerm_network_security_group" "sql_terraform_nsg" {
  name                = "${random_pet.prefix.id}-nsg"
  location            = azurerm_resource_group.sqlresourcegroup.location
  resource_group_name = azurerm_resource_group.sqlresourcegroup.name
  # SSH access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # JDWP access
  security_rule {
    name                       = "jdwp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5050"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "sql_terraform_vnet" {
  name                = "${random_pet.prefix.id}-vnet"
  resource_group_name = azurerm_resource_group.sqlresourcegroup.name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.sqlresourcegroup.location
}

# Create a subnet
resource "azurerm_subnet" "sql_terraform_subnet" {
  name                 = "${random_pet.prefix.id}-subnet"
  resource_group_name  = azurerm_resource_group.sqlresourcegroup.name
  virtual_network_name = azurerm_virtual_network.sql_terraform_vnet.name
  address_prefixes     = ["10.0.0.0/27"]

  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# Associate subnet and the security group
resource "azurerm_subnet_network_security_group_association" "sql_subnet_nsg_asn" {
  subnet_id                 = azurerm_subnet.sql_terraform_subnet.id
  network_security_group_id = azurerm_network_security_group.sql_terraform_nsg.id
}

# Create a route table
resource "azurerm_route_table" "sql_route_table" {
  name                          = "${random_pet.prefix.id}-rt"
  location                      = azurerm_resource_group.sqlresourcegroup.location
  resource_group_name           = azurerm_resource_group.sqlresourcegroup.name
  disable_bgp_route_propagation = false
}

# Associate subnet and the route table
resource "azurerm_subnet_route_table_association" "sql_subnet_rt_asn" {
  subnet_id      = azurerm_subnet.sql_terraform_subnet.id
  route_table_id = azurerm_route_table.sql_route_table.id

  depends_on = [azurerm_subnet_network_security_group_association.sql_subnet_nsg_asn]
}

# Create public IPs, must be STATIC to be accessible before it's assigned to a VM
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.sqlresourcegroup.location
  resource_group_name = azurerm_resource_group.sqlresourcegroup.name
  allocation_method   = "Static"
}

# Create network interface
resource "azurerm_network_interface" "sql_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.sqlresourcegroup.location
  resource_group_name = azurerm_resource_group.sqlresourcegroup.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.sql_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sql_nic_nsg_asn" {
  network_interface_id      = azurerm_network_interface.sql_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.sql_terraform_nsg.id
}
