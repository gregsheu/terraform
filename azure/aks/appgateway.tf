#resource "azurerm_resource_group" "main" {
#  name     = "default-resources"
#  location = "West US 2"
#}

resource "azurerm_virtual_network" "default" {
  name                = "default-network"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
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

resource "azurerm_public_ip" "default" {
  name                = "default-pip"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

## since these variables are re-used - a locals block makes this more maintainable
#locals {
#  frontend_port_name             = "${azurerm_virtual_network.default.name}-feport"
#  frontend_ip_configuration_name = "${azurerm_virtual_network.default.name}-feip"
#  http_setting_name              = "${azurerm_virtual_network.default.name}-be-htst"
#  listener_name                  = "${azurerm_virtual_network.default.name}-httplstn"
#  request_routing_rule_name      = "${azurerm_virtual_network.default.name}-rqrt"
#  redirect_configuration_name    = "${azurerm_virtual_network.default.name}-rdrcfg"
#  backend_address_pool_name      = "${azurerm_virtual_network.default.name}-backend"
#}
#
#resource "azurerm_application_gateway" "network" {
#  name                = "default-appgateway"
#  resource_group_name = azurerm_resource_group.default.name
#  location            = azurerm_resource_group.default.location
#
#  sku {
#    name     = "Standard_v2"
#    tier     = "Standard_v2"
#    capacity = 2
#  }
#
#  gateway_ip_configuration {
#    name      = "my-gateway-ip-configuration"
#    subnet_id = azurerm_subnet.frontend.id
#  }
#
#  frontend_port {
#    name = local.frontend_port_name
#    port = 80
#  }
#
#  frontend_ip_configuration {
#    name                 = local.frontend_ip_configuration_name
#    public_ip_address_id = azurerm_public_ip.default.id
#  }
#
#  backend_address_pool {
#    name = local.backend_address_pool_name
#  }
#
#  backend_http_settings {
#    name                  = local.http_setting_name
#    cookie_based_affinity = "Disabled"
#    path                  = "/healthz/"
#    port                  = 80
#    protocol              = "Http"
#    request_timeout       = 60
#  }
#
#  http_listener {
#    name                           = local.listener_name
#    frontend_ip_configuration_name = local.frontend_ip_configuration_name
#    frontend_port_name             = local.frontend_port_name
#    protocol                       = "Http"
#  }
#
#  request_routing_rule {
#    name                       = local.request_routing_rule_name
#    rule_type                  = "PathBasedRouting"
#    http_listener_name         = local.listener_name
#    backend_address_pool_name  = local.backend_address_pool_name
#    backend_http_settings_name = local.http_setting_name
#    url_path_map_name          = "defaultmap" 
#    priority                   = 9
#  }
#
#  url_path_map { 
#    name  = "defaultmap" 
#    default_backend_address_pool_name = local.backend_address_pool_name
#    default_backend_http_settings_name = local.http_setting_name
#    #default_redirect_configuration_name = "default-redirect" 
#    path_rule { 
#      name = "defaultrule" 
#      paths = ["/healthz/"] 
#      backend_address_pool_name = local.backend_address_pool_name
#      backend_http_settings_name = local.http_setting_name
#    } 
#  }
#  depends_on = [azurerm_virtual_network.default, azurerm_resource_group.default]
#}
