data "azurerm_kubernetes_cluster" "default" {
  name                = "${var.name}-aks"
  resource_group_name = "${var.name}-rg"
}
