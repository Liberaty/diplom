output "service_account_id" {
  value       = yandex_iam_service_account.terraform.id
  description = "ID of the created service account"
}

output "service_account_keys" {
  value = {
    access_key = yandex_iam_service_account_static_access_key.static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.static-key.secret_key
  }
  sensitive = true
}

output "cicd_service_account_id" {
  value       = yandex_iam_service_account.cicd.id
  description = "ID of the created CI/CD service account"
}

output "cicd_service_account_keys" {
  value = {
    access_key = yandex_iam_service_account_static_access_key.cicd-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.cicd-static-key.secret_key
  }
  sensitive = true
  description = "CI/CD service account credentials for GitHub Secrets"
}