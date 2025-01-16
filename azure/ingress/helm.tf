resource "helm_release" "nginx" {
  name = "nginx-ingress"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  create_namespace = true
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  #set {
  #  name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
  #  value = "/healthz"
  #}
  set {
    name = "kubernetes\\.io/ingress.class"
    value = "azure/application-gateway"
  }
  set {
    name = "appgw\\.ingress\\.kubernetes\\.io/backend-path-prefix"
    value = "/healthz"
  }
  #set {
  #  name  = "clusterName"
  #  value = azurerm_kubernetes_cluster.default.name
  #}

  #set {
  #  name  = "serviceAccount.name"
  #  value = "aws-load-balancer-controller"
  #}
}
