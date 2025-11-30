terraform {
  backend "s3" {
    endpoint   = "https://storage.yandexcloud.net"
    bucket     = "lepishin-tfstate"
    key        = "terraform.tfstate"
    region     = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}