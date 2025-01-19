#resource "local_file" "kubeconfig" {
#  content  = <<EOL
#apiVersion: v1
#kind: Config
#clusters:
#- name: "kubernetes"
#  cluster:
#    certificate-authority-data: "${data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate}"
#    server: "${data.azurerm_kubernetes_cluster.aks.kube_config.0.host}"
#contexts:
#- name: "kubernetes-context"
#  context:
#    cluster: "kubernetes"
#    user: "kubernetes-user"
#current-context: "kubernetes-context"
#users:
#- name: "kubernetes-user"
#  u}

resource "local_file" "kubeconfig" {
  content = templatefile("${path.module}/kubeconfig.tpl", {
    host = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate = data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
    client_key = data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key
    cluster_ca_certificate = data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  })
  filename = "${path.module}/kubeconfig.yaml"
} 
