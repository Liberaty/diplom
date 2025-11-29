resource "yandex_container_registry" "this" {
  name = var.ycr_name
}

resource "yandex_container_registry_iam_binding" "public_access" {
  registry_id = yandex_container_registry.this.id
  role        = "container-registry.viewer"

  members = [
    "system:allUsers"
  ]
}