#locals {
#  frontend_port_name             = "${terraform.workspace}-${azurerm_virtual_network.network.name}-feport"
#  frontend_ip_configuration_name = "${terraform.workspace}-${azurerm_virtual_network.network.name}-feip"
#  http_setting_name              = "${terraform.workspace}-${azurerm_virtual_network.network.name}-be-htst"
#  listener_name                  = "${terraform.workspace}-${azurerm_virtual_network.network.name}-httplstn"
#  request_routing_rule_name      = "${terraform.workspace}-${azurerm_virtual_network.network.name}-rqrt"
#  redirect_configuration_name    = "${terraform.workspace}-${azurerm_virtual_network.network.name}-rdrcfg"
#  backend_address_pool_name      = "${terraform.workspace}-${azurerm_virtual_network.network.name}-backend"
#}
#
#resource "azurerm_resource_group" "ag" {
#  name     = "${terraform.workspace}-ag-rg"
#  location = "West US 2"
#}
#
#resource "azurerm_application_gateway" "ag" {
#  name                = "${terraform.workspace}-ag"
#  resource_group_name = azurerm_resource_group.ag.name
#  location            = azurerm_resource_group.ag.location
#
#  sku {
#    name     = "Standard_v2"
#    tier     = "Standard_v2"
#    capacity = 2
#  }
#
#  gateway_ip_configuration {
#    name      = "${terraform.workspace}-ag-ip-conf"
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
#    public_ip_address_id = azurerm_public_ip.ag.id
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
#    name  = "${terraform.workspace}-urlpathmap" 
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
#  depends_on = [azurerm_virtual_network.network, azurerm_resource_group.ag]
#}
