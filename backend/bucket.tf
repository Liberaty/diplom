// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "lepishin" {
  access_key = var.access_key
  secret_key = var.secret_key
  bucket     = var.bucket_name
  max_size   = 1073741824 # 1 Gb

  versioning {
    enabled = true
  }
}
resource "yandex_storage_bucket_grant" "lepishin-grant" {
  bucket = var.bucket_name
  grant {
    id          = "ajebo0ffdtr1rcqr5p75"
    permissions = ["READ", "WRITE"]
    type        = "CanonicalUser"
  }
}