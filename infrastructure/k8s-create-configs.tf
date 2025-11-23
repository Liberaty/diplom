data "template_file" "deployment" {
  template = file("${path.module}/../k8s-configs/templates/deployment.yaml.tmpl")
  vars = {
    REGISTRY = "cr.yandex/${yandex_container_registry.this.id}"
    IMAGE_NAME     = "test-nginx-app"
    APP_NAME       = "test-nginx"
    IMAGE_TAG      = "1.29.3"
    NAMESPACE      = "lepishin-nginx"
    REPLICA_COUNT  = 2
  }
  depends_on = [
    yandex_container_registry.this
  ]
}

resource "local_file" "deployment_rendered" {
  content  = data.template_file.deployment.rendered
  filename = "${path.module}/../k8s-configs/deployment.yaml"
}