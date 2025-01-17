#resource "kubernetes_namespace_v1" "nginx" {
#  metadata {
#    name = "ingress-nginx"
#    labels = {
#      istio-injection = "enabled"
#    }
#  }
#}

resource "helm_release" "nginx" {
  name = "nginx-ingress"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  cleanup_on_fail = true
  create_namespace = true
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    #name = "service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    #name = "service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  #set {
  #  name = "kubernetes\\.io/ingress.class"
  #  value = "azure/application-gateway"
  #}
  #set {
  #  name = "appgw\\.ingress\\.kubernetes\\.io/backend-path-prefix"
  #  value = "/healthz"
  #}
  #set {
  #  name  = "clusterName"
  #  value = azurerm_kubernetes_cluster.default.name
  #}

  #set {
  #  name  = "serviceAccount.name"
  #  value = "aws-load-balancer-controller"
  #}
}

resource "kubernetes_ingress_v1" "nginx_ag" {
  #wait_for_load_balancer = true
  metadata {
    name      = "nginx-internal"
    namespace = "ingress-nginx"
  }
  spec {
    ingress_class_name = "azure-application-gateway"
    rule {
      http {
        path {
          path = "/"
          backend {
            service { 
              #name = "nginx-ingress-ingress-nginx-controller.ingress-nginx.svc.cluster.local"
              name = "nginx-ingress-ingress-nginx-controller"
              port { 
                number = 80 
              }
            }
          }
        }
      }
    }
  }
}

resource "helm_release" "istio" {
  name = "istio"
  namespace = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  create_namespace = true
  cleanup_on_fail = true
  set {
    name = "defaultRevision"
    value = "default"
  }
}

resource "helm_release" "istiod" {
  name = "istiod"
  namespace = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "istiod"
  cleanup_on_fail = true
  create_namespace = true
  #set {
  #  name  = "service.type"
  #  value = "ClusterIP"
  #}
}

resource "helm_release" "istio-gateway" {
  name = "istio-gateway"
  namespace = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "gateway"
  cleanup_on_fail = true
  create_namespace = true
  #set {
  #  name  = "service.type"
  #  value = "ClusterIP"
  #}
}

resource "terraform_data" "prometheus_addon" {
  provisioner "local-exec" {
    on_failure = continue
    command = "kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/prometheus.yaml"
  }
  triggers_replace = {
    ts = timestamp()
  }
  depends_on = [helm_release.istiod]
}

resource "helm_release" "kiali" {
  name = "kiali"
  namespace = "istio-system"
  repository = "https://kiali.org/helm-charts"
  chart = "kiali-server"
  cleanup_on_fail = true
  create_namespace = true
  set {
    name  = "auth.strategy"
    value = "anonymous"
  }
  set {
    name = "cr.spec.deployment.resources.requests.cpu"
    value = "500m"
  }
  depends_on = [helm_release.istiod]
}

resource "helm_release" "prometheus" {
  name = "prometheus"
  namespace = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  create_namespace = true
}

resource "kubernetes_labels" "nginx" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "ingress-nginx"
  }
  labels = {
    istio-injection = "enabled"
  }
}

resource "terraform_data" "restart" {
  provisioner "local-exec" {
    on_failure = continue
    command = "kubectl rollout restart deploy -n ingress-nginx nginx-ingress-ingress-nginx-controller"
  }
  triggers_replace = {
    ts = timestamp()
  }
  depends_on = [kubernetes_labels.nginx]
}
