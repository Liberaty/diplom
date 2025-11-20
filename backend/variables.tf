###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  sensitive   = true
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive   = true
}

variable "bucket_name" {
  type        = string
  default     = "lepishin-tfstate"
}

variable "access_key" {
  type        = string
  description = "Service account access key"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "Service account secret key"
  sensitive   = true
}