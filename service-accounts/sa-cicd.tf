resource "yandex_iam_service_account" "cicd" {
  name        = "cicd"
  description = "Service account for CI/CD"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.cicd.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.cicd.id}"
}

resource "yandex_iam_service_account_static_access_key" "cicd-static-key" {
  service_account_id = yandex_iam_service_account.cicd.id
  description        = "Static access key for CI/CD"
}