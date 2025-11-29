data "template_file" "deployment" {
  template = file("${path.module}/../k8s-configs/templates/deployment.yaml.tmpl")
  vars = {
    REGISTRY = "cr.yandex/${yandex_container_registry.this.id}"
    IMAGE_NAME     = "test-app"
    APP_NAME       = "test-nginx"
    IMAGE_TAG      = "1.0.0"
    NAMESPACE      = "lepishin-nginx"
    REPLICA_COUNT  = 3
  }
  depends_on = [
    yandex_container_registry.this
  ]
}

resource "local_file" "deployment_rendered" {
  content  = data.template_file.deployment.rendered
  filename = "${path.module}/../k8s-configs/deployment.yaml"
}

data "template_file" "namespace" {
  template = file("${path.module}/../k8s-configs/templates/namespace.yaml.tmpl")
  vars = {
    NAMESPACE      = "lepishin-nginx"
  }
}

resource "local_file" "namespace_rendered" {
  content  = data.template_file.namespace.rendered
  filename = "${path.module}/../k8s-configs/namespace.yaml"
}

data "template_file" "service" {
  template = file("${path.module}/../k8s-configs/templates/service.yaml.tmpl")
  vars = {
    APP_NAME       = "test-nginx"
    NAMESPACE      = "lepishin-nginx"
  }
}

resource "local_file" "service_rendered" {
  content  = data.template_file.service.rendered
  filename = "${path.module}/../k8s-configs/service.yaml"
}

data "template_file" "app_ingress" {
  template = file("${path.module}/../k8s-configs/templates/app-ingress.yaml.tmpl")
  vars = {
    APP_NAME       = "test-nginx"
    NAMESPACE      = "lepishin-nginx"
  }
}

resource "local_file" "app_ingress_rendered" {
  content  = data.template_file.app_ingress.rendered
  filename = "${path.module}/../k8s-configs/app-ingress.yaml"
}

data "template_file" "grafana_ingress" {
  template = file("${path.module}/../k8s-configs/templates/grafana-ingress.yaml.tmpl")
  vars = {
    APP_NAME       = "kube-prometheus-grafana"
    NAMESPACE      = "monitoring"
  }
}

resource "local_file" "grafana_ingress_rendered" {
  content  = data.template_file.grafana_ingress.rendered
  filename = "${path.module}/../k8s-configs/grafana-ingress.yaml"
}