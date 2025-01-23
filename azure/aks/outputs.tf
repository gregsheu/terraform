# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "ingress_user" {
  value = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].client_id
}

output "aks_user" {
  value = azurerm_user_assigned_identity.aks.principal_id
}
