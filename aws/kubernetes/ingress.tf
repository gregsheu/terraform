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
    name = "controller.replicaCount" 
    value = "2" 
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  #Keeps here for reference
  #set {
  #  name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
  #  value = "true"
  #}
  depends_on = [helm_release.ekslb]
}

resource "kubernetes_ingress_v1" "nginx_alb" {
  wait_for_load_balancer = true
  metadata {
    name      = "nginx"
    namespace = "ingress-nginx"
    annotations = {
      "alb.ingress.kubernetes.io/group.name" = "default"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port" = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-healthy-threshold-count" = "3"
      "alb.ingress.kubernetes.io/healthcheck-unhealthy-threshold-count" = "3"
      "alb.ingress.kubernetes.io/healthcheck-success-codes" = "200,404"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/subnets" = join(",", data.aws_subnets.public.ids)
      "external-dns.alpha.kubernetes.io/hostname" = "ayademogreg.myvnc.com,aspnetapp.myvnc.com"
      "external-dns.alpha.kubernetes.io/ingress-hostname-source" = "annotation-only"
    }
  }
  spec {
    ingress_class_name = "alb"
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
  depends_on = [helm_release.nginx]
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

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  depends_on = [helm_release.istiod]
}

resource "terraform_data" "prometheus_addon" {
  provisioner "local-exec" {
    on_failure = continue
    command = "kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/prometheus.yaml 2>/dev/null"
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

#resource "helm_release" "prometheus" {
#  name = "prometheus"
#  namespace = "prometheus"
#  repository = "https://prometheus-community.github.io/helm-charts"
#  chart = "prometheus"
#  create_namespace = true
#}

#resource "kubernetes_labels" "nginx" {
#  api_version = "v1"
#  kind        = "Namespace"
#  metadata {
#    name = "ingress-nginx"
#  }
#  labels = {
#    istio-injection = "enabled"
#  }
#  depends_on = [helm_release.nginx]
#}

#resource "terraform_data" "restart" {
#  provisioner "local-exec" {
#    on_failure = continue
#    command = "kubectl rollout restart deploy -n ingress-nginx nginx-ingress-ingress-nginx-controller 2>/dev/null"
#  }
#  triggers_replace = {
#    ts = timestamp()
#  }
#  depends_on = [kubernetes_labels.nginx]
#}
