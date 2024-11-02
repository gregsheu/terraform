resource "kubernetes_namespace_v1" "demo" {
  metadata {
    name = "ayademo"
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
