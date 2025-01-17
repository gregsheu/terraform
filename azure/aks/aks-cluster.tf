resource "azurerm_resource_group" "default" {
  name     = "${var.name}-rg"
  location = "West US 2"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.name}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.name}-k8s"
  kubernetes_version  = "1.29.9"
  default_node_pool {
    name            = var.name
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
    environment = var.name
  }
  #depends_on = [azurerm_application_gateway.network]
}
