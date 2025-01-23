resource "kubernetes_namespace_v1" "flux" {
  metadata {
    name = "flux-system"
  }
}

resource "azurerm_kubernetes_cluster_extension" "aks_fluxcd" {
  name           = "${terraform.workspace}-aks-fluxcd"
  cluster_id     = data.azurerm_kubernetes_cluster.aks.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "aks_fluxcd" {
  name       = "${terraform.workspace}-aks-fluxcd-fc"
  cluster_id = data.azurerm_kubernetes_cluster.aks.id
  namespace  = "flux-system"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }
  kustomizations {
    name = "kustomization-1"
    post_build {
      substitute = {
        aks_fluxcd_var = "substitute_with_this"
      }
      substitute_from {
        kind = "ConfigMap"
        name = "aks_fluxcd-configmap"
      }
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.aks_fluxcd
  ]
}
