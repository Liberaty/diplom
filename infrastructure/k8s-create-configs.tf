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

data "template_file" "atlantis_ns" {
  template = file("${path.module}/../k8s-configs/templates/atlantis_ns.yaml.tmpl")
  vars = {
    NAMESPACE      = "atlantis"
    TAG            = "atlantis"
  }
}

resource "local_file" "atlantis_ns_rendered" {
  content  = data.template_file.atlantis_ns.rendered
  filename = "${path.module}/../k8s-configs/atlantis/atlantis_ns.yaml"
}

data "template_file" "atlantis_cm" {
  template = file("${path.module}/../k8s-configs/templates/atlantis_cm.yaml.tmpl")
  vars = {
    NAMESPACE      = "atlantis"
  }
}

resource "local_file" "atlantis_cm_rendered" {
  content  = data.template_file.atlantis_cm.rendered
  filename = "${path.module}/../k8s-configs/atlantis/atlantis_cm.yaml"
}

data "template_file" "atlantis_svc" {
  template = file("${path.module}/../k8s-configs/templates/atlantis_svc.yaml.tmpl")
  vars = {
    NAMESPACE      = "atlantis"
    APP_NAME       = "atlantis"
  }
}

resource "local_file" "atlantis_svc_rendered" {
  content  = data.template_file.atlantis_svc.rendered
  filename = "${path.module}/../k8s-configs/atlantis/atlantis_svc.yaml"
}

data "template_file" "atlantis_dt" {
  template = file("${path.module}/../k8s-configs/templates/atlantis_dt.yaml.tmpl")
  vars = {
    NAMESPACE      = "atlantis"
    APP_NAME       = "atlantis"
    REPLICA_COUNT  = 1
  }
}

resource "local_file" "atlantis_dt_rendered" {
  content  = data.template_file.atlantis_dt.rendered
  filename = "${path.module}/../k8s-configs/atlantis/atlantis_dt.yaml"
}