resource "azurerm_resource_group" "aks" {
  name     = "${terraform.workspace}-aks-rg"
  location = "West US 2"

  tags = {
    environment = "${terraform.workspace}-aks-rg"
  }
}

resource "azurerm_virtual_network" "network" {
  name                = "${terraform.workspace}-ag-network"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "${terraform.workspace}-ag-frontend"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "${terraform.workspace}-ag-backend"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.254.2.0/24"]
  #delegation {
  #  name = "delegation"
  #  service_delegation {
  #    name    = "Microsoft.Network/applicationGateways"
  #    actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #  }
  #}
  #delegation {
  #  name = "delegation"
  #  service_delegation {
  #    name    = "Microsoft.ContainerInstance/containerGroups"
  #    actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #  }
  #}
}

resource "azurerm_public_ip" "ag" {
  name                = "${terraform.workspace}-ag-public-ip"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  allocation_method   = "Static"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${terraform.workspace}-aks-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${terraform.workspace}-aks-k8s"
  kubernetes_version  = "1.29.9"
  default_node_pool {
    name            = "${terraform.workspace}aksnp"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
    vnet_subnet_id = azurerm_subnet.backend.id
  }

  #https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
  #Please ensure the identity used by AGIC has the Microsoft.Network/virtualNetworks/subnets/join/action permission delegated
  #identity {
  #  type = "SystemAssigned"
  #}

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  ingress_application_gateway {
    #gateway_id = azurerm_application_gateway.network.id
    #subnet_cidr = ["10.225.0.0/16"]
    subnet_id = azurerm_subnet.frontend.id
  }

  tags = {
    environment = "${terraform.workspace}-aks"
  }
  #depends_on = [azurerm_application_gateway.network]
}
