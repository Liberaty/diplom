output "bucket_name" {
  value       = yandex_storage_bucket.lepishin.bucket
  description = "Name of the created S3 bucket"
}