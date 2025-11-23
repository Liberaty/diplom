###cloud vars
variable "cloud_id" {
  type        = string
  sensitive   = true
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  sensitive   = true
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_k8s_name" {
  type        = string
  default     = "network-netology"
  description = "Network for my diplom"
}

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2204-lts-oslogin"
}

variable "ssh_username" {
  type        = string
  sensitive   = true
  description = "username for VMs with k8s"
}

variable "ssh_pub_key" {
  type        = string
  sensitive   = true
  description = "public key for VMs with k8s"
}

variable "ansible_inventory_path" {
  description = "Путь к ansible inventory относительно каталога infrastructure"
  type        = string
  default     = "../ansible/kubespray/inventory/mycluster/inventory.ini"
}

variable "ycr_name" {
  type        = string
  description = "Yandex Container Registry Name"
  default     = "lepishin-registry"
}

variable "k8s_vm_worker" {
  type = list(object({
    name          = string
    platform_id   = string
    zone          = string
    nat_ip        = bool
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    name_disk     = string
    hdd_type      = string
  }))
  default = [
    {
      name          = "worker"
      platform_id   = "standard-v3"
      zone          = "ru-central1-a"
      nat_ip        = true
      cores         = 2
      memory        = 4
      core_fraction = 50
      hdd_size      = 15
      name_disk     = "SSD"
      hdd_type      = "network-ssd"
    },
    {
      name          = "worker"
      platform_id   = "standard-v3"
      zone          = "ru-central1-b"
      nat_ip        = true
      cores         = 2
      memory        = 4
      core_fraction = 50
      hdd_size      = 15
      name_disk     = "SSD"
      hdd_type      = "network-ssd"
    },
    {
      name          = "worker"
      platform_id   = "standard-v3"
      zone          = "ru-central1-d"
      nat_ip        = true
      cores         = 2
      memory        = 4
      core_fraction = 50
      hdd_size      = 15
      name_disk     = "SSD"
      hdd_type      = "network-ssd"
    }
  ]
}

variable "k8s_vm_master" {
  type = list(object({
    name          = string
    platform_id   = string
    zone          = string
    nat_ip        = bool
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    name_disk     = string
    hdd_type      = string
  }))
  default = [
    {
      name          = "master"
      platform_id   = "standard-v3"
      zone          = "ru-central1-a"
      nat_ip        = true
      cores         = 2
      memory        = 4
      core_fraction = 50
      hdd_size      = 15
      name_disk     = "SSD"
      hdd_type      = "network-ssd"
    }
  ]
}
