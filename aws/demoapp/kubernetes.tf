resource "kubernetes_namespace_v1" "demo" {
  metadata {
    name = "ayademo"
    #labels = {
    #  istio-injection = "enabled"
    #}
  }
}

resource "kubernetes_deployment_v1" "demo" {
  metadata {
    name      = "ayademo"
    namespace = kubernetes_namespace_v1.demo.metadata.0.name
    labels = {
      app = "ayademo"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "ayademo"
      }
    }
    template {
      metadata {
        labels = {
          app = "ayademo"
        }
      }
      spec {
        container {
          image = "httpd"
          name  = "ayademo"

          resources {
            limits = {
              memory = "512M"
              cpu    = "1"
            }
            requests = {
              memory = "256M"
              cpu    = "50m"
            }
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "demo" {
  metadata {
    name      = "ayademo"
    namespace = kubernetes_namespace_v1.demo.metadata.0.name
  }
  spec {
    selector = { 
      app = kubernetes_deployment_v1.demo.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "demo" {
  #wait_for_load_balancer = true
  metadata {
    name      = "ayademo"
    namespace = kubernetes_namespace_v1.demo.metadata.0.name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "ayademogreg.myvnc.com"
      http {
        path {
          path = "/"
          backend {
            service { 
              name = kubernetes_service_v1.demo.metadata.0.name
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

resource "kubernetes_namespace_v1" "aspnet" {
  metadata {
    name = "aspnetapp"
    #labels = {
    #  istio-injection = "enabled"
    #}
  }
}

resource "kubernetes_deployment_v1" "aspnet" {
  metadata {
    name      = "aspnetapp"
    namespace = kubernetes_namespace_v1.aspnet.metadata.0.name
    labels = {
      app = "aspnetapp"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "aspnetapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "aspnetapp"
        }
      }
      spec {
        container {
          image = "mcr.microsoft.com/dotnet/samples:aspnetapp"
          name  = "aspnetapp"

          resources {
            limits = {
              memory = "512M"
              cpu    = "1"
            }
            requests = {
              memory = "256M"
              cpu    = "50m"
            }
          }
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "aspnet" {
  metadata {
    name      = "aspnetapp"
    namespace = kubernetes_namespace_v1.aspnet.metadata.0.name
  }
  spec {
    selector = { 
      app = kubernetes_deployment_v1.aspnet.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "aspnet" {
  #wait_for_load_balancer = true
  metadata {
    name      = "aspnetapp"
    namespace = kubernetes_namespace_v1.aspnet.metadata.0.name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "aspnetapp.myvnc.com"
      http {
        path {
          path = "/"
          backend {
            service { 
              name = kubernetes_service_v1.aspnet.metadata.0.name
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

#resource "kubernetes_ingress_v1" "apps" {
#  #wait_for_load_balancer = true
#  metadata {
#    name      = "appsingress"
#    namespace = "ingress-nginx"
#  }
#  spec {
#    ingress_class_name = "nginx"
#    rule {
#      host = "aspnetapp.myvnc.com"
#      http {
#        path {
#          path = "/"
#          backend {
#            service { 
#              name = "${kubernetes_service_v1.aspnet.metadata.0.name}"
#              port { 
#                number = 80 
#              }
#            }
#          }
#        }
#      }
#    }
#    rule {
#      host = "ayademogreg.myvnc.com"
#      http {
#        path {
#          path = "/"
#          backend {
#            service { 
#              name = "${kubernetes_service_v1.demo.metadata.0.name}"
#              port { 
#                number = 80 
#              }
#            }
#          }
#        }
#      }
#    }
#  }
#}
