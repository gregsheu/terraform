data "azurerm_kubernetes_cluster" "aks" {
  name                = "${terraform.workspace}-aks-cluster"
  resource_group_name = "${terraform.workspace}-aks-rg"
}
